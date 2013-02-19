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


void showErrorMessage(NSError *error, NSString *errorMessage)
{
    NSLog(@"Error %@ your Xcode System Code Snippets file:\n%@", errorMessage, [error localizedDescription]);
}


NSString *replaceRegexpWithTemplateForString(NSString *pattern, NSString *template, NSString *string)
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    if (regex)
    {
        NSRange theWholeThing = NSMakeRange(0, [string length]);
        
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:theWholeThing];
        NSLog(@"Number of matches: %lu", numberOfMatches);
        
        return [regex stringByReplacingMatchesInString:string options:0 range:theWholeThing withTemplate:template];
    }
    else
    {
        NSLog(@"Error in regular expression: %@\n%@", pattern, [error localizedDescription]);
        return nil;
    }
}


void backupTheSnippetsFileIfNecessary()
{
    
    // The path to back up the SystemCodeSnippets file to.
    NSString *snippetsBackupFilePath = [NSHomeDirectory() stringByAppendingString:@"/SystemCodeSnippets.codesnippets"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:snippetsBackupFilePath])
    {
        // A backup does not exist, make one.
        NSLog(@"Backing up the Xcode System Code Snippets file…");

        NSError *error = nil;
        if ([[NSFileManager defaultManager] copyItemAtPath:kSystemCodeSnippetsFilePath toPath:snippetsBackupFilePath error:&error])
        {
            NSLog(@"…done.");
        }
        else
        {
            showErrorMessage(error, @"backing up");
        }
    }
}


void updateTheXcodeSystemCodeSnippetsFile()
{
    NSLog(@"Updating the Xcode System Code Snippets file…");
    
    NSError *error = nil;
    NSString *systemCodeSnippets = [[NSString alloc] initWithContentsOfFile:kSystemCodeSnippetsFilePath encoding:NSUTF8StringEncoding error:&error];
    if (systemCodeSnippets)
    {
        NSString *elsesEtc = replaceRegexpWithTemplateForString(@"\\} (.*?) \\{", @"\\}\n$1\n\\{", systemCodeSnippets);
        
        // Replace curly brackets on line ends with ones on the next line.
        NSString *bracesOnNewLine = replaceRegexpWithTemplateForString(@"[ ]\\{", @"\n{", elsesEtc);
        
        // Note: 2 levels of indentation (8 spaces) is currently the max in the file; hardcoded for that.
        NSString *fixedSecondLevelIndentation = replaceRegexpWithTemplateForString(@"^\\{\n        ", @"    {\n        ", bracesOnNewLine);
        
        NSString *fixedThatElse = replaceRegexpWithTemplateForString(@"^else\n    \\{", @"    else\n    \\{", fixedSecondLevelIndentation);
        
        NSString *finalVersion = fixedThatElse;
        
        NSLog(@"Final version: %@", finalVersion);
    }
    else
    {
        showErrorMessage(error, @"reading");
    }    
}


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        backupTheSnippetsFileIfNecessary();
        updateTheXcodeSystemCodeSnippetsFile();
    }
    return 0;
}

