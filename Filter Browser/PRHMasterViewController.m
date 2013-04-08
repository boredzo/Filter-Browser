//
//  PRHMasterViewController.m
//  Filter Browser
//
//  Created by Peter Hosey on 2013-04-07.
//  Copyright (c) 2013 Peter Hosey. All rights reserved.
//

#import "PRHMasterViewController.h"

#import "PRHDetailViewController.h"

@interface PRHMasterViewController () {
	NSArray *_filterCategoryNames;
    NSMutableArray *_objects;
}
@end

@implementation PRHMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;

	_filterCategoryNames = [self discoverAllCategoryNames];
}

- (NSArray *) discoverAllCategoryNames {
	NSMutableSet *allCategoryNamesSet = [NSMutableSet new];

	NSArray *allFilterNames = [CIFilter filterNamesInCategories:nil];
	for (NSString *filterName in allFilterNames) {
		@autoreleasepool {
			CIFilter *filter = [CIFilter filterWithName:filterName];
			NSDictionary *attributes = filter.attributes;
			NSArray *filterCategoryNames = attributes[kCIAttributeFilterCategories];
			[allCategoryNamesSet unionSet:[NSSet setWithArray:filterCategoryNames]];
		}
	}

	return [[allCategoryNamesSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _filterCategoryNames.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return _filterCategoryNames[section];
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *sectionIndexTitles = [@[ ] mutableCopy];
	for (__strong NSString *categoryName in _filterCategoryNames) {
		NSString *appleCategoryPrefix = @"CICategory";
		if ([categoryName hasPrefix:appleCategoryPrefix])
			categoryName = [categoryName substringFromIndex:appleCategoryPrefix.length];

		NSString *firstThreeLetters;
		if ([categoryName isEqualToString:@"HighDynamicRange"])
			firstThreeLetters = @"HDR";
		else {
			firstThreeLetters = [categoryName substringToIndex:MIN(3, [categoryName length])];

			//TODO: De-dupe “ColorAdjustment” and “ColorEffect” (which both truncate to “Col”) to “C.Adj” and “C.Eff” or something like that
		}

		[sectionIndexTitles addObject:firstThreeLetters];
	}
	return sectionIndexTitles;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSString *selectedCategoryName = _filterCategoryNames[section];
	NSArray *filterNames = [self filterNamesInCategory:selectedCategoryName];
	return filterNames.count;
}

- (NSArray *) filterNamesInCategory:(NSString *)categoryName {
	return [CIFilter filterNamesInCategory:categoryName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	NSString *categoryName = _filterCategoryNames[indexPath.section];
	NSArray *filterNames = [self filterNamesInCategory:categoryName];
	cell.textLabel.text = filterNames[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
