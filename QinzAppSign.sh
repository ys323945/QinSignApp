
#获取手动创建的APP文件夹，用来放置越狱版本的Ipa包,${SRCROOT} 代表工程文件所在的目录
crackPath="${SRCROOT}/APP"
#获取越狱版本Ipa路径
oldIpaPath="${crackPath}/*.ipa"
# 创建一个临时文件夹，用来放置解压的Ipa文件
tempPath="${SRCROOT}/Temp"

#首先先清空Temp文件夹
rm -rf "$tempPath"
#创建临时文件夹目录
mkdir -p "$tempPath"


# 1. 解压IPA到temp下
unzip -oqq "$oldIpaPath" -d "$tempPath"
# 拿到解压的临时的APP的路径
oldIPaPath=$(set -- "$tempPath/Payload/"*.app;echo "$1")

# 2. 将解压出来的.app拷贝进入工程下
# BUILT_PRODUCTS_DIR 工程生成的APP包的路径(系统创建的)
# TARGET_NAME target名称(系统创建的)
targetAppPath="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
# 打印app编译后的路径
echo "app路径:$targetAppPath"

#先删除app所在路径文件
rm -rf "$targetAppPath"
#重新创建该文件路径
mkdir -p "$targetAppPath"
#将解压的app文件拷贝到Xcode编译的app文件目录，让Xcode认为这是它编译出来的，Xcode就会帮我们完成签名工作
cp -rf "$oldIPaPath/" "$targetAppPath"


# 3. 删除extension和WatchAPP.个人证书没法签名Extention
rm -rf "$targetAppPath/PlugIns"
rm -rf "$targetAppPath/Watch"


# 4. 更新info.plist文件 CFBundleIdentifier,PlistBuddy是更改plist文件的可执行文件
#  设置:"Set : KEY Value" "目标文件路径"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$targetAppPath/Info.plist"


# 5. 重签名第三方 FrameWorks
tagetAppFramworkPath="$targetAppPath/Frameworks"
if [ -d "$tagetAppFramworkPath" ];
then
for frameWork in "$tagetAppFramworkPath/"*
do

#签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$frameWork"
done
fi








