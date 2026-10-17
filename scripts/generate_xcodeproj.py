#!/usr/bin/env python3
import os
import re

def generate_pbxproj():
    project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    xcodeproj_dir = os.path.join(project_dir, "SpotifyWidget.xcodeproj")
    os.makedirs(xcodeproj_dir, exist_ok=True)
    xcschemes_dir = os.path.join(xcodeproj_dir, "xcshareddata", "xcschemes")
    os.makedirs(xcschemes_dir, exist_ok=True)

    template = """// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		B10001 /* PlaybackState.swift in Sources (App) */ = {isa = PBXBuildFile; fileRef = F10001 /* PlaybackState.swift */; };
		B10002 /* SpotifyBridge.swift in Sources (App) */ = {isa = PBXBuildFile; fileRef = F10002 /* SpotifyBridge.swift */; };
		B10003 /* SpotifyScriptingProtocol.swift in Sources (App) */ = {isa = PBXBuildFile; fileRef = F10003 /* SpotifyScriptingProtocol.swift */; };
		B10004 /* SharedDataManager.swift in Sources (App) */ = {isa = PBXBuildFile; fileRef = F10004 /* SharedDataManager.swift */; };
		B10005 /* SystemPermissionManager.swift in Sources (App) */ = {isa = PBXBuildFile; fileRef = F10005 /* SystemPermissionManager.swift */; };
		B10006 /* SpotifyWidgetApp.swift in Sources (App) */ = {isa = PBXBuildFile; fileRef = F10006 /* SpotifyWidgetApp.swift */; };
		B10007 /* ContentView.swift in Sources (App) */ = {isa = PBXBuildFile; fileRef = F10007 /* ContentView.swift */; };
		B10008 /* HostAppViewModel.swift in Sources (App) */ = {isa = PBXBuildFile; fileRef = F10008 /* HostAppViewModel.swift */; };
		B10009 /* SpotifyWidgetExtension.appex in Embed App Extensions */ = {isa = PBXBuildFile; fileRef = P20001 /* SpotifyWidgetExtension.appex */; settings = {ATTRIBUTES = (RemoveHeadersOnCopy, ); }; };

		B20001 /* PlaybackState.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F10001 /* PlaybackState.swift */; };
		B20002 /* SpotifyBridge.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F10002 /* SpotifyBridge.swift */; };
		B20003 /* SpotifyScriptingProtocol.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F10003 /* SpotifyScriptingProtocol.swift */; };
		B20004 /* SharedDataManager.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F10004 /* SharedDataManager.swift */; };
		B20005 /* SystemPermissionManager.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F10005 /* SystemPermissionManager.swift */; };
		B20006 /* SpotifyWidgetBundle.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F20001 /* SpotifyWidgetBundle.swift */; };
		B20007 /* SpotifyWidget.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F20002 /* SpotifyWidget.swift */; };
		B20008 /* WidgetViews.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F20003 /* WidgetViews.swift */; };
		B20009 /* SpotifyIntents.swift in Sources (Widget) */ = {isa = PBXBuildFile; fileRef = F20004 /* SpotifyIntents.swift */; };

		B30001 /* main.swift in Sources (Harness) */ = {isa = PBXBuildFile; fileRef = F30001 /* main.swift */; };
		B30002 /* PlaybackState.swift in Sources (Harness) */ = {isa = PBXBuildFile; fileRef = F10001 /* PlaybackState.swift */; };
		B30003 /* SpotifyBridge.swift in Sources (Harness) */ = {isa = PBXBuildFile; fileRef = F10002 /* SpotifyBridge.swift */; };
		B30004 /* SpotifyScriptingProtocol.swift in Sources (Harness) */ = {isa = PBXBuildFile; fileRef = F10003 /* SpotifyScriptingProtocol.swift */; };
		B30005 /* SharedDataManager.swift in Sources (Harness) */ = {isa = PBXBuildFile; fileRef = F10004 /* SharedDataManager.swift */; };
		B30006 /* SystemPermissionManager.swift in Sources (Harness) */ = {isa = PBXBuildFile; fileRef = F10005 /* SystemPermissionManager.swift */; };
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
		PX0001 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = PR0001 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = T20001 /* SpotifyWidgetExtension */;
			remoteInfo = SpotifyWidgetExtension;
		};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
		CP0001 /* Embed App Extensions */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 13;
			files = (
				B10009 /* SpotifyWidgetExtension.appex in Embed App Extensions */,
			);
			name = "Embed App Extensions";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
		P10001 /* Widgit.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Widgit.app; sourceTree = BUILT_PRODUCTS_DIR; };
		P20001 /* SpotifyWidgetExtension.appex */ = {isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = SpotifyWidgetExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; };
		P30001 /* SpotifyHarness */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; path = SpotifyHarness; sourceTree = BUILT_PRODUCTS_DIR; };

		F10001 /* PlaybackState.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PlaybackState.swift; sourceTree = "<group>"; };
		F10002 /* SpotifyBridge.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpotifyBridge.swift; sourceTree = "<group>"; };
		F10003 /* SpotifyScriptingProtocol.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpotifyScriptingProtocol.swift; sourceTree = "<group>"; };
		F10004 /* SharedDataManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SharedDataManager.swift; sourceTree = "<group>"; };
		F10005 /* SystemPermissionManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SystemPermissionManager.swift; sourceTree = "<group>"; };

		F10006 /* SpotifyWidgetApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpotifyWidgetApp.swift; sourceTree = "<group>"; };
		F10007 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		F10008 /* HostAppViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HostAppViewModel.swift; sourceTree = "<group>"; };
		F10009 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		F10010 /* SpotifyWidgetApp.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = SpotifyWidgetApp.entitlements; sourceTree = "<group>"; };

		F20001 /* SpotifyWidgetBundle.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpotifyWidgetBundle.swift; sourceTree = "<group>"; };
		F20002 /* SpotifyWidget.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpotifyWidget.swift; sourceTree = "<group>"; };
		F20003 /* WidgetViews.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WidgetViews.swift; sourceTree = "<group>"; };
		F20004 /* SpotifyIntents.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpotifyIntents.swift; sourceTree = "<group>"; };
		F20005 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		F20006 /* SpotifyWidgetExtension.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = SpotifyWidgetExtension.entitlements; sourceTree = "<group>"; };

		F30001 /* main.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = main.swift; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		FW1001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		FW2001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		FW3001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		G00001 = {
			isa = PBXGroup;
			children = (
				G10000 /* Sources */,
				G40000 /* Products */,
			);
			sourceTree = "<group>";
		};
		G10000 /* Sources */ = {
			isa = PBXGroup;
			children = (
				G10001 /* SpotifyBridgeKit */,
				G10002 /* SpotifyWidgetApp */,
				G10003 /* SpotifyWidgetExtension */,
				G10004 /* SpotifyHarness */,
			);
			path = Sources;
			sourceTree = "<group>";
		};
		G10001 /* SpotifyBridgeKit */ = {
			isa = PBXGroup;
			children = (
				F10001 /* PlaybackState.swift */,
				F10002 /* SpotifyBridge.swift */,
				F10003 /* SpotifyScriptingProtocol.swift */,
				F10004 /* SharedDataManager.swift */,
				F10005 /* SystemPermissionManager.swift */,
			);
			path = SpotifyBridgeKit;
			sourceTree = "<group>";
		};
		G10002 /* SpotifyWidgetApp */ = {
			isa = PBXGroup;
			children = (
				F10006 /* SpotifyWidgetApp.swift */,
				F10007 /* ContentView.swift */,
				F10008 /* HostAppViewModel.swift */,
				F10009 /* Info.plist */,
				F10010 /* SpotifyWidgetApp.entitlements */,
			);
			path = SpotifyWidgetApp;
			sourceTree = "<group>";
		};
		G10003 /* SpotifyWidgetExtension */ = {
			isa = PBXGroup;
			children = (
				F20001 /* SpotifyWidgetBundle.swift */,
				F20002 /* SpotifyWidget.swift */,
				F20003 /* WidgetViews.swift */,
				F20004 /* SpotifyIntents.swift */,
				F20005 /* Info.plist */,
				F20006 /* SpotifyWidgetExtension.entitlements */,
			);
			path = SpotifyWidgetExtension;
			sourceTree = "<group>";
		};
		G10004 /* SpotifyHarness */ = {
			isa = PBXGroup;
			children = (
				F30001 /* main.swift */,
			);
			path = SpotifyHarness;
			sourceTree = "<group>";
		};
		G40000 /* Products */ = {
			isa = PBXGroup;
			children = (
				P10001 /* Widgit.app */,
				P20001 /* SpotifyWidgetExtension.appex */,
				P30001 /* SpotifyHarness */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		T10001 /* SpotifyWidgetApp */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = C10001 /* Build configuration list for PBXNativeTarget "SpotifyWidgetApp" */;
			buildPhases = (
				S10001 /* Sources */,
				FW1001 /* Frameworks */,
				CP0001 /* Embed App Extensions */,
			);
			buildRules = (
			);
			dependencies = (
				D10001 /* PBXTargetDependency */,
			);
			name = SpotifyWidgetApp;
			productName = Widgit;
			productReference = P10001 /* Widgit.app */;
			productType = "com.apple.product-type.application";
		};
		T20001 /* SpotifyWidgetExtension */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = C20001 /* Build configuration list for PBXNativeTarget "SpotifyWidgetExtension" */;
			buildPhases = (
				S20001 /* Sources */,
				FW2001 /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = SpotifyWidgetExtension;
			productName = SpotifyWidgetExtension;
			productReference = P20001 /* SpotifyWidgetExtension.appex */;
			productType = "com.apple.product-type.app-extension";
		};
		T30001 /* SpotifyHarness */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = C30001 /* Build configuration list for PBXNativeTarget "SpotifyHarness" */;
			buildPhases = (
				S30001 /* Sources */,
				FW3001 /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = SpotifyHarness;
			productName = SpotifyHarness;
			productReference = P30001 /* SpotifyHarness */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		PR0001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = C00001 /* Build configuration list for PBXProject "SpotifyWidget" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = G00001;
			productRefGroup = G40000 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				T10001 /* SpotifyWidgetApp */,
				T20001 /* SpotifyWidgetExtension */,
				T30001 /* SpotifyHarness */,
			);
		};
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
		S10001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				B10001 /* PlaybackState.swift in Sources (App) */,
				B10002 /* SpotifyBridge.swift in Sources (App) */,
				B10003 /* SpotifyScriptingProtocol.swift in Sources (App) */,
				B10004 /* SharedDataManager.swift in Sources (App) */,
				B10005 /* SystemPermissionManager.swift in Sources (App) */,
				B10006 /* SpotifyWidgetApp.swift in Sources (App) */,
				B10007 /* ContentView.swift in Sources (App) */,
				B10008 /* HostAppViewModel.swift in Sources (App) */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		S20001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				B20001 /* PlaybackState.swift in Sources (Widget) */,
				B20002 /* SpotifyBridge.swift in Sources (Widget) */,
				B20003 /* SpotifyScriptingProtocol.swift in Sources (Widget) */,
				B20004 /* SharedDataManager.swift in Sources (Widget) */,
				B20005 /* SystemPermissionManager.swift in Sources (Widget) */,
				B20006 /* SpotifyWidgetBundle.swift in Sources (Widget) */,
				B20007 /* SpotifyWidget.swift in Sources (Widget) */,
				B20008 /* WidgetViews.swift in Sources (Widget) */,
				B20009 /* SpotifyIntents.swift in Sources (Widget) */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		S30001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				B30001 /* main.swift in Sources (Harness) */,
				B30002 /* PlaybackState.swift in Sources (Harness) */,
				B30003 /* SpotifyBridge.swift in Sources (Harness) */,
				B30004 /* SpotifyScriptingProtocol.swift in Sources (Harness) */,
				B30005 /* SharedDataManager.swift in Sources (Harness) */,
				B30006 /* SystemPermissionManager.swift in Sources (Harness) */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		D10001 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = T20001 /* SpotifyWidgetExtension */;
			targetProxy = PX0001 /* PBXContainerItemProxy */;
		};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
		CFG001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Manual;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		CFG002 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Manual;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
		CFG101 /* Debug (App) */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_ENTITLEMENTS = Sources/SpotifyWidgetApp/SpotifyWidgetApp.entitlements;
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Manual;
				COMBINE_HIDPI_IMAGES = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Sources/SpotifyWidgetApp/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.widgit.SpotifyWidgetApp;
				PRODUCT_NAME = Widgit;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		CFG102 /* Release (App) */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_ENTITLEMENTS = Sources/SpotifyWidgetApp/SpotifyWidgetApp.entitlements;
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Manual;
				COMBINE_HIDPI_IMAGES = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Sources/SpotifyWidgetApp/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.widgit.SpotifyWidgetApp;
				PRODUCT_NAME = Widgit;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
		CFG201 /* Debug (Widget) */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_ENTITLEMENTS = Sources/SpotifyWidgetExtension/SpotifyWidgetExtension.entitlements;
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Manual;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Sources/SpotifyWidgetExtension/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
					"@executable_path/../../../../Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.widgit.SpotifyWidgetApp.Widget;
				PRODUCT_NAME = SpotifyWidgetExtension;
				SKIP_INSTALL = YES;
				SWIFT_VERSION = 5.0;
				WRAPPER_EXTENSION = appex;
			};
			name = Debug;
		};
		CFG202 /* Release (Widget) */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_ENTITLEMENTS = Sources/SpotifyWidgetExtension/SpotifyWidgetExtension.entitlements;
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Manual;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Sources/SpotifyWidgetExtension/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
					"@executable_path/../../../../Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.widgit.SpotifyWidgetApp.Widget;
				PRODUCT_NAME = SpotifyWidgetExtension;
				SKIP_INSTALL = YES;
				SWIFT_VERSION = 5.0;
				WRAPPER_EXTENSION = appex;
			};
			name = Release;
		};
		CFG301 /* Debug (Harness) */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Manual;
				PRODUCT_NAME = SpotifyHarness;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		CFG302 /* Release (Harness) */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Manual;
				PRODUCT_NAME = SpotifyHarness;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		C00001 /* Build configuration list for PBXProject "SpotifyWidget" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				CFG001 /* Debug */,
				CFG002 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		C10001 /* Build configuration list for PBXNativeTarget "SpotifyWidgetApp" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				CFG101 /* Debug (App) */,
				CFG102 /* Release (App) */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		C20001 /* Build configuration list for PBXNativeTarget "SpotifyWidgetExtension" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				CFG201 /* Debug (Widget) */,
				CFG202 /* Release (Widget) */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		C30001 /* Build configuration list for PBXNativeTarget "SpotifyHarness" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				CFG301 /* Debug (Harness) */,
				CFG302 /* Release (Harness) */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

	};
	rootObject = PR0001 /* Project object */;
}
"""

    # Generate 24-char hex IDs
    # Map each short tag to a deterministic 24-character hexadecimal string
    id_map = {}
    category_prefixes = {
        'PR': '000000',
        'T':  '100000',
        'C':  '200000',
        'CFG':'300000',
        'G':  '400000',
        'F':  '500000',
        'P':  '600000',
        'B':  '700000',
        'S':  '800000',
        'FW': '810000',
        'CP': '820000',
        'D':  '900000',
        'PX': '910000',
    }

    tokens = set(re.findall(r'\b([A-Z]{1,3}\d{4,5})\b', template))
    for t in sorted(tokens):
        m = re.match(r'^([A-Z]+)(\d+)$', t)
        alpha, num = m.group(1), m.group(2)
        hex_prefix = category_prefixes.get(alpha, 'AA0000')
        padded = f"{hex_prefix}{num.zfill(18)}"
        id_map[t] = padded

    # Replace all tokens in template
    final_pbxproj = template
    for short_id, full_hex in id_map.items():
        final_pbxproj = re.sub(rf'\b{short_id}\b', full_hex, final_pbxproj)

    with open(os.path.join(xcodeproj_dir, "project.pbxproj"), "w") as f:
        f.write(final_pbxproj)

    app_target_hex = id_map['T10001']
    ext_target_hex = id_map['T20001']

    scheme_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{app_target_hex}"
               BuildableName = "Widgit.app"
               BlueprintName = "SpotifyWidgetApp"
               ReferencedContainer = "container:SpotifyWidget.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{ext_target_hex}"
               BuildableName = "SpotifyWidgetExtension.appex"
               BlueprintName = "SpotifyWidgetExtension"
               ReferencedContainer = "container:SpotifyWidget.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_hex}"
            BuildableName = "Widgit.app"
            BlueprintName = "SpotifyWidgetApp"
            ReferencedContainer = "container:SpotifyWidget.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_hex}"
            BuildableName = "Widgit.app"
            BlueprintName = "SpotifyWidgetApp"
            ReferencedContainer = "container:SpotifyWidget.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
    with open(os.path.join(xcschemes_dir, "SpotifyWidgetApp.xcscheme"), "w") as f:
        f.write(scheme_content)

    print("Generated SpotifyWidget.xcodeproj with 24-char hex UUIDs successfully.")

if __name__ == "__main__":
    generate_pbxproj()
