@echo off

if not exist atlas_builder\atlas_builder.exe (
    odin build atlas_builder/ -out:atlas_builder/atlas_builder.exe
)

if not exist file_version_builder\file_version_builder.exe (
    odin build file_version_builder/ -out:file_version_builder/file_version_builder.exe
)
