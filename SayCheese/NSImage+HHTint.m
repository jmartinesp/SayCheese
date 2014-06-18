/*
 * Copyright (c) 2012, Pierre Bernard & Houdah Software s.à r.l.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "NSImage+HHTint.h"

#if __has_feature(objc_arc)
#define HH_AUTORELEASE(x) x
#else
#define HH_AUTORELEASE(x) [x autorelease];
#endif

#import <QuartzCore/QuartzCore.h>


@implementation NSImage (HHTint)

- (NSImage *)hh_imageTintedWithColor:(NSColor *)tint
{
	if (tint != nil) {
		CIFilter *colorGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
		CIColor *color = HH_AUTORELEASE([[CIColor alloc] initWithColor:tint]);

		[colorGenerator setValue:color forKey:kCIInputColorKey];

		CIFilter *colorFilter = [CIFilter filterWithName:@"CIColorControls"];

		[colorFilter setValue:[colorGenerator valueForKey:kCIOutputImageKey] forKey:kCIInputImageKey];
		[colorFilter setValue:[NSNumber numberWithFloat:3.0] forKey:kCIInputSaturationKey];
		[colorFilter setValue:[NSNumber numberWithFloat:0.35] forKey:kCIInputBrightnessKey];
		[colorFilter setValue:[NSNumber numberWithFloat:1.0] forKey:kCIInputContrastKey];

		CIFilter *monochromeFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
		CIImage *baseImage = [CIImage imageWithData:[self TIFFRepresentation]];

		[monochromeFilter setValue:baseImage forKey:kCIInputImageKey];
		[monochromeFilter setValue:[CIColor colorWithRed:0.75 green:0.75 blue:0.75] forKey:kCIInputColorKey];
		[monochromeFilter setValue:[NSNumber numberWithFloat:0.2] forKey:kCIInputIntensityKey];

		CIFilter *compositingFilter = [CIFilter filterWithName:@"CIMultiplyCompositing"];

		[compositingFilter setValue:[colorFilter valueForKey:kCIOutputImageKey] forKey:kCIInputImageKey];
		[compositingFilter setValue:[monochromeFilter valueForKey:kCIOutputImageKey] forKey:kCIInputBackgroundImageKey];

		CIImage *outputImage = [compositingFilter valueForKey:kCIOutputImageKey];

		CGRect extend = [outputImage extent];
        CGSize size = self.size;
		NSImage *tintedImage = HH_AUTORELEASE([[NSImage alloc] initWithSize: size]);

		[tintedImage lockFocus];
		{
			CGContextRef contextRef = [[NSGraphicsContext currentContext] graphicsPort];
			CIContext *ciContext = [CIContext contextWithCGContext:contextRef
														   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
																							   forKey:kCIContextUseSoftwareRenderer]];
            CGRect rect = CGRectMake(0, 0, size.width, size.height);
            [ciContext drawImage:outputImage inRect:rect fromRect:extend];
		}
		[tintedImage unlockFocus];

		return tintedImage;
	}
	else {
		return HH_AUTORELEASE([self copy]);
	}
}

@end