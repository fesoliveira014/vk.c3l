module vk_loader_test;

import vk;

const ZString MISSING_LOADER = "vk-c3l-test-missing-loader";

fn void loader_reports_a_missing_library_and_loads_the_default() @test {
    assert(vk::set_loader_library(MISSING_LOADER));
    assert(@catch(vk::load_loader()) == vk::LOADER_NOT_FOUND);
    assert(!vk::is_loader_loaded());
    uint version;
    assert(vk::enumerate_instance_version(&version) == vk::Result.ERROR_INITIALIZATION_FAILED);
    assert(vk::get_instance_proc_addr((vk::Instance)null, "vkCreateInstance") == null);

    assert(vk::set_loader_library(null));
    vk::load_loader()!!;
    assert(vk::is_loader_loaded());
    assert(vk::loader_missing_command() == null);
    vk::load_loader()!!;
    assert(!vk::set_loader_library(MISSING_LOADER));
    assert(vk::enumerate_instance_version(&version) == vk::Result.SUCCESS);
    assert(version >= (1u << 22 | 1u << 12));
    assert(vk::get_instance_proc_addr((vk::Instance)null, "vkCreateInstance") != null);
}
