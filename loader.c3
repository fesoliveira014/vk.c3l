module vk;

import std::atomic;
import std::atomic::types;
import std::os;
import std::thread;
import vk::entry_points;

faultdef
    // The Vulkan loader library could not be opened: no Vulkan runtime is installed.
    LOADER_NOT_FOUND,
    // The loader opened but does not export every Vulkan 1.3 core command.
    LOADER_INCOMPLETE;

<* The library load_loader opens unless set_loader_library chose another. *>
const ZString DEFAULT_LOADER_LIBRARY = env::WIN32
    ? "vulkan-1.dll"
    : env::DARWIN ? "libvulkan.1.dylib" : "libvulkan.so.1";

const int LOADER_UNLOADED @private = 0;
const int LOADER_BUSY     @private = 1;
const int LOADER_LOADED   @private = 2;

Atomic{int} loader_state @private;
ZString loader_library @private = DEFAULT_LOADER_LIBRARY;
DylibHandle loader_handle @private;
ZString loader_missing @private;

<* Open the Vulkan loader and resolve every core command it exports.
   Thread-safe and idempotent: once it succeeds, later calls return at once and
   the loader stays open until the process exits. A failed call keeps nothing
   open, and a later call tries again. The global commands (vkCreateInstance,
   the instance enumerations and vkGetInstanceProcAddr) call it on first use, so
   calling it first is needed only to learn why Vulkan is unavailable.
   @return? LOADER_NOT_FOUND, LOADER_INCOMPLETE *>
fn void? load_loader() {
    if (!acquire_loader_state()) return;
    fault failure = @catch(open_loader());
    loader_state.store(failure ? LOADER_UNLOADED : LOADER_LOADED, AtomicOrdering.RELEASE);
    if (failure) return failure~;
}

<* Report whether the core commands are callable, loading the loader if needed. *>
fn bool ensure_loader() {
    if (loader_state.load(AtomicOrdering.ACQUIRE) == LOADER_LOADED) return true;
    return @ok(load_loader());
}

<* Report whether a load succeeded, without loading. *>
fn bool is_loader_loaded() => loader_state.load(AtomicOrdering.ACQUIRE) == LOADER_LOADED;

<* Choose the library a later load opens: a file name searched the way the
   system searches for libraries, or a path. Has no effect once a load
   succeeded. The name is borrowed until a load succeeds or another is set.
   @param name : "Library name or path; null restores DEFAULT_LOADER_LIBRARY."
   @return "False when the loader is already loaded and the name was not taken." *>
fn bool set_loader_library(ZString name) {
    if (!acquire_loader_state()) return false;
    loader_library = name ? name : DEFAULT_LOADER_LIBRARY;
    loader_state.store(LOADER_UNLOADED, AtomicOrdering.RELEASE);
    return true;
}

<* The first core command the last failed load found missing, for diagnostics.
   @return "A command name after LOADER_INCOMPLETE, otherwise null." *>
fn ZString loader_missing_command() => loader_missing;

<* Take the loader state for an update, waiting out a load on another thread.
   @return "True when the caller now holds the state, false when it is loaded." *>
fn bool acquire_loader_state() @private {
    while (true) {
        int expected = LOADER_UNLOADED;
        if (loader_state.compare_exchange(
            &expected,
            LOADER_BUSY,
            AtomicOrdering.ACQUIRE,
            AtomicOrdering.ACQUIRE,
        )) return true;
        if (expected == LOADER_LOADED) return false;
        thread::yield();
    }
}

fn void? open_loader() @private {
    loader_missing = null;
    DylibHandle handle = os::dlopen(loader_library, { .resolve_now = true });
    if (!handle) return LOADER_NOT_FOUND~;
    loader_handle = handle;
    if (catch failure = entry_points::resolve(&lookup_loader_export, &loader_missing)) {
        loader_handle.close();
        return failure~;
    }
}

fn void* lookup_loader_export(ZString name) @private => os::dlsym(loader_handle, name);
