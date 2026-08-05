module vk_ray_query_test;

import vk;

fn void command_build_signature_probe(
    vk::CommandBuffer command_buffer,
    uint info_count,
    vk::AccelerationStructureBuildGeometryInfoKHR* infos,
    vk::AccelerationStructureBuildRangeInfoKHR** range_infos,
) {
    (void)command_buffer;
    (void)info_count;
    (void)infos;
    (void)range_infos;
}

fn void command_build_indirect_signature_probe(
    vk::CommandBuffer command_buffer,
    uint info_count,
    vk::AccelerationStructureBuildGeometryInfoKHR* infos,
    vk::DeviceAddress* indirect_addresses,
    uint* indirect_strides,
    uint** max_primitive_counts,
) {
    (void)command_buffer;
    (void)info_count;
    (void)infos;
    (void)indirect_addresses;
    (void)indirect_strides;
    (void)max_primitive_counts;
}

fn vk::Result host_build_signature_probe(
    vk::Device device,
    vk::DeferredOperationKHR deferred_operation,
    uint info_count,
    vk::AccelerationStructureBuildGeometryInfoKHR* infos,
    vk::AccelerationStructureBuildRangeInfoKHR** range_infos,
) {
    (void)device;
    (void)deferred_operation;
    (void)info_count;
    (void)infos;
    (void)range_infos;
    return vk::Result.SUCCESS;
}

fn void required_ray_query_binding_values_match_vulkan() @test {
    assert((uint)vk::DescriptorType.ACCELERATION_STRUCTURE_KHR == 1000150000);
    assert((uint)vk::StructureType
        .PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR == 1000150013);
    assert((uint)vk::StructureType.PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR
        == 1000348013);
    assert((uint)vk::BufferUsageFlagBits
        .ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR == 0x00080000);
    assert((uint)vk::BufferUsageFlagBits
        .ACCELERATION_STRUCTURE_STORAGE_BIT_KHR == 0x00100000);
    assert((ulong)vk::PipelineStageFlagBits2
        .STAGE_2_ACCELERATION_STRUCTURE_BUILD_BIT_KHR == 0x02000000);
    assert((ulong)vk::AccessFlagBits2
        .ACCESS_2_ACCELERATION_STRUCTURE_READ_BIT_KHR == 0x00200000);
    assert((ulong)vk::AccessFlagBits2
        .ACCESS_2_ACCELERATION_STRUCTURE_WRITE_BIT_KHR == 0x00400000);
}

fn void required_ray_query_builders_initialize_chain_types() @test {
    vk::PhysicalDeviceAccelerationStructureFeaturesKHR acceleration_features =
        vk::physical_device_acceleration_structure_features_khr();
    vk::PhysicalDeviceRayQueryFeaturesKHR ray_query_features =
        vk::physical_device_ray_query_features_khr();
    vk::PhysicalDeviceAccelerationStructurePropertiesKHR properties =
        vk::physical_device_acceleration_structure_properties_khr();
    vk::AccelerationStructureGeometryTrianglesDataKHR triangles =
        vk::acceleration_structure_geometry_triangles_data_khr();
    vk::AccelerationStructureGeometryAabbsDataKHR aabbs =
        vk::acceleration_structure_geometry_aabbs_data_khr();
    vk::AccelerationStructureGeometryInstancesDataKHR instances =
        vk::acceleration_structure_geometry_instances_data_khr();

    assert(acceleration_features.s_type
        == vk::StructureType.PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR);
    assert(ray_query_features.s_type
        == vk::StructureType.PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR);
    assert(properties.s_type
        == vk::StructureType.PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_PROPERTIES_KHR);
    assert(triangles.s_type
        == vk::StructureType.ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR);
    assert(aabbs.s_type
        == vk::StructureType.ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR);
    assert(instances.s_type
        == vk::StructureType.ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR);
}

fn void command_build_uses_an_array_of_range_info_pointers() @test {
    vk::PFN_vkCmdBuildAccelerationStructuresKHR command =
        &command_build_signature_probe;
    assert(command != null);
}

fn void indirect_and_host_builds_use_pointer_arrays() @test {
    vk::PFN_vkCmdBuildAccelerationStructuresIndirectKHR indirect_command =
        &command_build_indirect_signature_probe;
    vk::PFN_vkBuildAccelerationStructuresKHR host_command =
        &host_build_signature_probe;

    assert(indirect_command != null);
    assert(host_command != null);
}
