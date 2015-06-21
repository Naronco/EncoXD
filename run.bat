pushd gui
if /I %1==Game call .\run.bat
popd

dub test --config=%*
