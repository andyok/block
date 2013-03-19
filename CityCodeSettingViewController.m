//
//  CityCodeSettingViewController.m
//  UXinClient
//
//  Created by Lenya Han on 4/19/12.
//  Copyright (c) 2012 D-TONG-TELECOM. All rights reserved.
//

#import "CityCodeSettingViewController.h"
#import "PhoneNumberAttribution.h"
#import "fontConfig.h"

#define ID_TAG_SWITCH       1101    // 开关按钮ID
2222
33
@implementation CityCodeSettingViewController

@synthesize isCallIN;
@synthesize delegate = _delegate;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"设置区号";

    // 背景图片
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    background.image = [UIImage imageNamed:@"background.png"];
    [self.view addSubview:background];
    [background release]; 
    
    // Table View
    UITableView *pTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStyleGrouped];
    [pTableView setSeparatorColor:SEPARATOR_COLOR];
	pTableView.backgroundColor = [UIColor clearColor];
    pTableView.backgroundView = nil;
    pTableView.scrollEnabled = NO;
	pTableView.delegate = self;
	pTableView.dataSource = self;
	[self.view addSubview:pTableView];
    pTableView.rowHeight = 40;
	[pTableView release];
    
    // 右导航键
    UIBarButtonItem *ubbi = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(OKToSave)];
    self.navigationItem.rightBarButtonItem = ubbi;
    [ubbi release]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
#pragma mark Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
    cell.textLabel.font = TABLE_TITLE_FONT;
    cell.detailTextLabel.font = TABLE_DESCRIPTION_FONT;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) 
    {
        cell.textLabel.text = @"区号:";
        
        cityCodeField = [[UITextField alloc] initWithFrame:CGRectMake(80, 10, 320 - 110, 20)];
        cityCodeField.delegate = self;
        cityCodeField.placeholder = @"";
        cityCodeField.text = [CommonFunc GetLocalDataString:DATA_CITY_CODE];
        cityCodeField.keyboardType = UIKeyboardTypeNumberPad;
        cityCodeField.font = TABLE_DESCRIPTION_FONT;
        cityCodeField.textColor = TABLE_DESCRIPTION_COLOR;
        cityCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cityCodeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        cityCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [cell.contentView addSubview:cityCodeField];
        
        // 初始获得焦点
        if (!isHiddenKeyBoard) 
        {
            [cityCodeField becomeFirstResponder];
        }
        [cityCodeField release];
    }
    
    return cell;
}

// TabView 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 40.0;
    }

    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
        UILabel *lable = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 40)]autorelease];
        lable.text = @"您可以在此设置默认区号，在呼叫时未加区号的号码会默认自动为您加拨此区号。";
        lable.textAlignment = UITextAlignmentLeft;
        lable.shadowColor = [UIColor whiteColor];
        lable.shadowOffset = CGSizeMake(0, 1 );
        lable.textColor = DESCRIPTION_FONT_COLOR;
        lable.numberOfLines = 0;
        lable.backgroundColor = [UIColor clearColor];
        lable.font = [UIFont systemFontOfSize:DESCRIPTION_FONT_SIZE];
        [footer addSubview:lable];
        return footer;
    }
    
    return nil;
}
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isHiddenKeyBoard = TRUE;
    if ([cityCodeField isFirstResponder]) 
    {
        [cityCodeField resignFirstResponder];
        return;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    isHiddenKeyBoard = TRUE;
    [textField resignFirstResponder];
    return YES;
}

-(void)OKToSave
{
    [MobClick event: @"ClickOKOnSetCityCode"];
    
    if (![cityCodeField.text length] > 0) 
    {
        [PublicFunc ShowMessageBox:1 titleName:nil contentText:L(@"city_number_null", nil) cancelBtnName:L(@"me_know",nil) delegate:nil];
        return;
    }
    
    if ([cityCodeField.text length] > 8) 
    {
        [PublicFunc ShowMessageBox:1 titleName:nil contentText:L(@"city_max_8", nil) cancelBtnName:L(@"me_know",nil) delegate:nil];
        return;
    }    
    
    [SVProgressHUD showInView: self.navigationController.view status: nil networkIndicator: NO posY: -1 maskType: SVProgressHUDMaskTypeClear];

    [CommonFunc SetLocalDataString:cityCodeField.text key:DATA_CITY_CODE];
    
    [SVProgressHUD dismissWithSuccess: @"设置成功" afterDelay: 1];
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dealloc
{
    [super dealloc];
}
@end
