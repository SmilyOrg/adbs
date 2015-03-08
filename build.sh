if [ "$1" = "cpp" ]; then
haxe build.hxml -cpp bin/cpp/
cp bin/cpp/ADBS.exe bin/adbs.exe
else
haxe build.hxml -neko bin/adbs.n
cd bin/
nekotools boot adbs.n
cd ../
fi