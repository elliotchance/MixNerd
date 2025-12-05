.build/release/MixNerd: Sources/MixNerd/*.swift
	swift build -c release

MixNerd.app/Contents:
	mkdir -p MixNerd.app/Contents

MixNerd.app/Contents/MacOS/MixNerd: MixNerd.app/Contents .build/release/MixNerd
	mkdir -p MixNerd.app/Contents/MacOS
	cp .build/release/MixNerd MixNerd.app/Contents/MacOS

MixNerd.app/Contents/Resources: MixNerd.app/Contents Sources/MixNerd/Resources
	cp -r Sources/MixNerd/Resources MixNerd.app/Contents

MixNerd.app/Contents/Info.plist: MixNerd.app/Contents Info.plist
	cp Info.plist MixNerd.app/Contents

clean:
	rm -rf MixNerd.app

MixNerd.app: MixNerd.app/Contents/MacOS/MixNerd MixNerd.app/Contents/Resources MixNerd.app/Contents/Info.plist

all: MixNerd.app

test:
	swift test -q
