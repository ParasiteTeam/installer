//
//  ParasiteRuntime.h
//  ParasiteRuntime
//
//  Created by Alexander Zielenski on 3/31/16.
//  Copyright © 2016 ParasiteTeam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for ParasiteRuntime.
FOUNDATION_EXPORT double ParasiteRuntimeVersionNumber;

//! Project version string for ParasiteRuntime.
FOUNDATION_EXPORT const unsigned char ParasiteRuntimeVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ParasiteRuntime/PublicHeader.h>


// Creates a function which is executed when the library loads
#define _PSNAME(NAME, LINE) _PSNAME2(NAME, LINE) // Preprocess hax to get the line to concat
#define _PSNAME2(NAME, LINE) NAME ## LINE
#define PSInitialize __attribute__((__constructor__)) static void _PSNAME(_PSInitialize, __LINE__) ()

#import <ParasiteRuntime/ZKSwizzle.h>
#import <ParasiteRuntime/PSHook.h>