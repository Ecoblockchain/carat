//
//  ProcessViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 13/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ProcessViewController.h"

@interface ProcessViewController ()

@end

@implementation ProcessViewController

static NSString * expandedCell = @"BugHogExpandedTableViewCell";
static NSString * collapsedCell = @"BugHogTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self creteData];
    NSLog(@"viewDidLoad tabledata count: %d", [_tableData count]);
    NSLog(@"viewDidLoad tableView ref: %@", _tableView);
    _expandedCells = [[NSMutableArray alloc]init];
    [_tableView registerNib:[UINib nibWithNibName:collapsedCell bundle:nil] forCellReuseIdentifier:collapsedCell];
    [_tableView registerNib:[UINib nibWithNibName:expandedCell bundle:nil] forCellReuseIdentifier:expandedCell];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (NSArray *)tableData
{
    if (!_tableData)
    {
        [self creteData];
    }
    return _tableData;
}

-(void) creteData{
    
    BugHogListItemData* d1 = [BugHogListItemData new];
    d1.imageName = @"Icon-Small-50";
    d1.title = @"Facebook";
    d1.expImpTxt = @"dunno what goes here";
    d1.samples = @"263";
    d1.error = @"49";
    d1.samplesWithout = @"2125454";
    
    BugHogListItemData* d2 = [BugHogListItemData new];
    d2.imageName = @"Icon-Small-50";
    d2.title = @"Instagram";
    d2.expImpTxt = @"dunno what goes here";
    d2.samples = @"120";
    d2.error = @"23";
    d2.samplesWithout = @"2125";
    
    BugHogListItemData* d3 = [BugHogListItemData new];
    d3.imageName = @"Icon-Small-50";
    d3.title = @"Googlemaps";
    d3.expImpTxt = @"dunno what goes here";
    d3.samples = @"50";
    d3.error = @"13";
    d3.samplesWithout = @"621254";
    
    _tableData = [[NSArray alloc] initWithObjects:d1, d2, d3, nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"tabledata count: %d", [_tableData count]);
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = nil;
    if ([self.expandedCells containsObject:indexPath])
    {
        cellIdentifier = expandedCell;
    }
    else{
        cellIdentifier = collapsedCell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BugHogListItemData *rowData = [_tableData objectAtIndex:indexPath.row];
    if ([[cell reuseIdentifier] isEqualToString:expandedCell]) {
        BugHogExpandedTableViewCell *expandedCell = (BugHogExpandedTableViewCell *)cell;
        expandedCell.nameLabel.text = rowData.title;
        expandedCell.thumbnailAppImg.image = [UIImage imageNamed:rowData.imageName];
        NSString *bodyText = NSLocalizedString(@"ExpectedImp", nil);
        NSMutableString *expImpLabelText = [[NSMutableString alloc]init];
        [expImpLabelText appendString:bodyText];
        [expImpLabelText appendString:rowData.expImpTxt];
        expandedCell.expImpTimeLabel.text = expImpLabelText;
        [expImpLabelText release];
        
        expandedCell.samplesValueLabel.text = rowData.samples;
        expandedCell.samplesWithoutValueLabel.text = rowData.samplesWithout;
        expandedCell.errorValueLabel.text = rowData.error;
    }
    else{
        BugHogTableViewCell *collapsedCell = (BugHogTableViewCell *)cell;
        collapsedCell.nameLabel.text = rowData.title;
        collapsedCell.thumbnailAppImg.image = [UIImage imageNamed:rowData.imageName];
        NSString *bodyText = NSLocalizedString(@"ExpectedImp", nil);
        NSMutableString *expImpLabelText = [[NSMutableString alloc]init];
        [expImpLabelText appendString:bodyText];
        [expImpLabelText appendString:rowData.expImpTxt];
        collapsedCell.expImpTimeLabel.text = expImpLabelText;
        [expImpLabelText release];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    
    if ([self.expandedCells containsObject:indexPath])
    {
        [self.expandedCells removeObject:indexPath];
    }
    else
    {
        [self.expandedCells addObject:indexPath];
    }
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
    [tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat kExpandedCellHeight = 196;
    CGFloat kNormalCellHeigh = 56;
    
    if ([self.expandedCells containsObject:indexPath])
    {
        return kExpandedCellHeight; //It's not necessary a constant, though
    }
    else
    {
        return kNormalCellHeigh; //Again not necessary a constant
    }
}


- (IBAction)showMessage
{
    UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                    initWithTitle:@"My First App" message:@"Hello, World!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display the Hello World Message
    [helloWorldAlert show];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)dealloc {
    [_tableData release];
    [_tableView release];
    [_expandedCells release];
    [super dealloc];
}
@end