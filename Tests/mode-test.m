/*
 * Diff Match and Patch
 *
 * Copyright 2011 geheimwerk.de.
 * http://code.google.com/p/google-diff-match-patch/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: fraser@google.com (Neil Fraser)
 * ObjC port: jan@geheimwerk.de (Jan Weiß)
 */

#import <Foundation/Foundation.h>

#import <DiffMatchPatch/DiffMatchPatch.h>

NSMutableArray * diff_defaultMode(NSString *text1, NSString *text2);
NSMutableArray * diff_lineMode(NSString *text1, NSString *text2);
NSMutableArray * diff_wordMode(NSString *text1, NSString *text2);

NSString * diff_stringForURL(NSURL *aURL);

NSMutableArray * diff_defaultMode(NSString *text1, NSString *text2) {
	DiffMatchPatch *dmp = [[DiffMatchPatch new] autorelease];
	
	dmp.Diff_Timeout = 0;
	NSMutableArray *diffs = [dmp diff_mainOfOldString:text1 andNewString:text2 checkLines:NO];
	
	return diffs;
}

NSMutableArray * diff_lineMode(NSString *text1, NSString *text2) {
	DiffMatchPatch *dmp = [[DiffMatchPatch new] autorelease];
	
	NSArray *a = [dmp diff_linesToCharsForFirstString:text1 andSecondString:text2];
	NSString *lineText1 = [a objectAtIndex:0];
	NSString *lineText2 = [a objectAtIndex:1];
	NSMutableArray *lineArray = [a objectAtIndex:2];
	
	dmp.Diff_Timeout = 0;
	NSMutableArray *diffs = [dmp diff_mainOfOldString:lineText1 andNewString:lineText2 checkLines:NO];
	
	[dmp diff_chars:diffs toLines:lineArray];
	return diffs;
}

NSMutableArray * diff_wordMode(NSString *text1, NSString *text2) {
	DiffMatchPatch *dmp = [[DiffMatchPatch new] autorelease];
	
	NSArray *a = [dmp diff_wordsToCharsForFirstString:text1 andSecondString:text2];
	NSString *lineText1 = [a objectAtIndex:0];
	NSString *lineText2 = [a objectAtIndex:1];
	NSMutableArray *lineArray = [a objectAtIndex:2];
	
	dmp.Diff_Timeout = 0;
	NSMutableArray *diffs = [dmp diff_mainOfOldString:lineText1 andNewString:lineText2 checkLines:NO];
	
	[dmp diff_chars:diffs toLines:lineArray];
	return diffs;
}

NSString * diff_stringForURL(NSURL *aURL) {
  NSDictionary *documentOptions = [NSDictionary dictionary];
  NSDictionary *documentAttributes;
  NSError *error;
  NSAttributedString *attributedString = [[NSAttributedString alloc]
                                          initWithURL:aURL
                                          options:documentOptions
                                          documentAttributes:&documentAttributes error:&error];
  if (!attributedString) {
    NSLog(@"%@", error);
  }
  NSString *string = [attributedString string];

  return [string autorelease];
}


typedef enum {
  DIFF_DEFAULT_MODE = 1,
  DIFF_LINE_MODE = 2,
  DIFF_WORD_MODE = 3
} Diff_Mode;


int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if ([[[NSProcessInfo processInfo] arguments] count] < 3) {
		fprintf(stderr, "usage: %s <txt1> <txt2> [default|line|word]\n",
            [[[NSProcessInfo processInfo] processName] UTF8String]);
		[pool drain];
		return EXIT_FAILURE;
	}

	NSString *rawFilePath1 = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
	NSString *rawFilePath2 = [[[NSProcessInfo processInfo] arguments] objectAtIndex:2];

  NSURL *fileURL1 = [NSURL fileURLWithPath:rawFilePath1];
	NSURL *fileURL2 = [NSURL fileURLWithPath:rawFilePath2];
  
  NSString *text1 = diff_stringForURL(fileURL1);
  NSString *text2 = diff_stringForURL(fileURL2);
  
  if (text1 == nil || text2 == nil) {
    return EXIT_FAILURE;
  }
  
  NSMutableArray *diffs;
  NSUInteger mode = DIFF_DEFAULT_MODE;
  
  if ([[[NSProcessInfo processInfo] arguments] count] >= 4) {
    NSString *modeString = [[[NSProcessInfo processInfo] arguments] objectAtIndex:3];
    
    if ([modeString isEqualToString:@"line"]) {
      mode = DIFF_LINE_MODE;
    }
    else if ([modeString isEqualToString:@"word"]) {
      mode = DIFF_WORD_MODE;
    }
  }
  
  switch (mode) {
    case DIFF_LINE_MODE:
      diffs = diff_lineMode(text1, text2);
      break;
    case DIFF_WORD_MODE:
      diffs = diff_wordMode(text1, text2);
      break;
    default:
      diffs = diff_defaultMode(text1, text2);
      break;
  }
  
  NSLog(@"%@", [diffs description]);
  
  [pool drain];
	return EXIT_SUCCESS;
}