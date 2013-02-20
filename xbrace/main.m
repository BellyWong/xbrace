//
//  main.m
//  xbrace
//
//  Changes the system code snippets for Xcode to place
//  all autocompleted opening curly braces on new lines.
//
//  Uses the technique outlined by Doug Stephen at
//  http://canadian-fury.com/2012/05/16/xcode-4-dot-3-place-all-autocompleted-opening-curly-braces-on-new-lines/
//
//  Also thanks to Leslie’s answer on StackOverflow for the path to the file
//  http://stackoverflow.com/a/9638657/253485
//
//  Created by Aral Balkan on 19/02/2013.
//  Copyright (c) 2013 Aral Balkan. Released under the MIT License.
//

#import <Foundation/Foundation.h>

#define kSystemCodeSnippetsFilePath   @"/Applications/Xcode.app/Contents/PlugIns/IDECodeSnippetLibrary.ideplugin/Contents/Resources/SystemCodeSnippets.codesnippets"


void output (NSString *format, ...) {
    //
    // This method courtesy of http://cocoaheads.byu.edu/wiki/different-nslog
    //
    if (format == nil) {
        printf("nil\n");
        return;
    }
    // Get a reference to the arguments that follow the format parameter
    va_list argList;
    va_start(argList, format);
    // Perform format string argument substitution, reinstate %% escapes, then print
    NSString *s = [[NSString alloc] initWithFormat:format arguments:argList];
    printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"] UTF8String]);
    va_end(argList);
}


void exitWithError(NSError *error, NSString *errorMessage)
{
    output(@"\t\033[7m⛔  Error %@ your Xcode System Code Snippets file.\033[0m\n\n\t\033[31m%@\033[39m", errorMessage, [error localizedDescription]);
    exit(EXIT_FAILURE);
}


NSString *replaceRegexpWithTemplateForString(NSString *pattern, NSString *template, NSString *string)
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    if (regex)
    {
        NSRange theWholeThing = NSMakeRange(0, [string length]);
        
        // NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:theWholeThing];
        // NSLog(@"Number of matches: %lu", numberOfMatches);
        
        return [regex stringByReplacingMatchesInString:string options:0 range:theWholeThing withTemplate:template];
    }
    else
    {
        output(@"> Error in regular expression: %@\n\033[31m%@\033[39m", pattern, [error localizedDescription]);
        exit(EXIT_FAILURE);
    }
}


void backupTheSnippetsFileIfNecessary()
{
    
    // The path to back up the SystemCodeSnippets file to.
    NSString *snippetsBackupFilePath = [NSHomeDirectory() stringByAppendingString:@"/SystemCodeSnippets.codesnippets"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:snippetsBackupFilePath])
    {
        NSError *error = nil;
        if ([[NSFileManager defaultManager] copyItemAtPath:kSystemCodeSnippetsFilePath toPath:snippetsBackupFilePath error:&error])
        {
            output(@"\t★ \033[94mBacked up the Xcode System Code Snippets file.\033[39m");
        }
        else
        {
            exitWithError(error, @"backing up");
        }
    }
    else
    {
        NSLog(@"File exists at %@", snippetsBackupFilePath);
    }
}

void updateTheXcodeSystemCodeSnippetsFile()
{
    NSError *error = nil;
    NSString *systemCodeSnippets = [[NSString alloc] initWithContentsOfFile:kSystemCodeSnippetsFilePath encoding:NSUTF8StringEncoding error:&error];
    if (systemCodeSnippets)
    {
        // Ugly code ahead…
        
        // Fix the } else {, etc. patterns.
        NSString *elsesEtc = replaceRegexpWithTemplateForString(@"\\} (.*?) \\{", @"\\}\n$1\n\\{", systemCodeSnippets);
        
        // Replace curly brackets on line ends with ones on the next line.
        NSString *bracesOnNewLine = replaceRegexpWithTemplateForString(@"[ ]\\{", @"\n{", elsesEtc);
        
        // 2 levels of indentation (8 spaces) is currently the max in the file; hardcoded for that.
        NSString *fixedSecondLevelIndentation = replaceRegexpWithTemplateForString(@"^\\{\n        ", @"    {\n        ", bracesOnNewLine);
        
        // Ah, that remaining else…
        NSString *fixedThatElse = replaceRegexpWithTemplateForString(@"^else\n    \\{", @"    else\n    \\{", fixedSecondLevelIndentation);
        
        NSString *finalVersion = fixedThatElse;
        
        // NSLog(@"Final version: %@", finalVersion);
        
        // Save it
        if ([finalVersion writeToFile:kSystemCodeSnippetsFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
        {
            output(@"\t★ Yay, your Xcode System Code Snippets file has been updated!");
            output(@"\t★ \033[7mPlease restart Xcode\033[0m and your braces should now be on the next line.\n\n");
        }
        else
        {
            exitWithError(error, @"saving");
        }
    }
    else
    {
        exitWithError(error, @"reading");
    }    
}


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        output(@"\n\tXbrace v0.0.1 by Aral Balkan\n\t____________________________\n");
        
        backupTheSnippetsFileIfNecessary();
        updateTheXcodeSystemCodeSnippetsFile();
    }
    return EXIT_SUCCESS;
}

