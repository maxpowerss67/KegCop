//
//  ViewControllerRootHomeLeftPanel.m
//  KegCop
//
//  Created by capin on 11/19/14.
//
//

#import "ViewControllerRootHomeLeftPanel.h"
#import "ViewControllerRootHome.h"
#import "ViewControllerRootHomeCenter.h"
#import "KCModalPickerView.h"
#import "ViewControllerUsers.h"
#import "Account.h"
#import "ViewControllerWebService.h"
#import "ViewControllerDev2.h"

#define SLIDE_TIMING .25

@interface ViewControllerRootHomeLeftPanel ()

@property (nonatomic, weak) IBOutlet UITableViewCell *cellMain;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *userNames;

@end

@implementation ViewControllerRootHomeLeftPanel {
    
}
@synthesize myDelegate;

- (UITableView *)makeTableView {
    CGFloat x = 0;
    CGFloat y = 50;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height - 50;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.rowHeight = 45;
    tableView.sectionFooterHeight = 22;
    tableView.sectionHeaderHeight = 22;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    return tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Core Data
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [[AccountsDataModel sharedDataModel]mainContext];
        NSLog(@"After _managedObjectContext: %@",  _managedObjectContext);
    }
    // tableView cell options
    _options = [[NSMutableArray alloc] initWithObjects:@"test", @"Manage Accounts", @"Add Credits", @"Change Pin", @"Logoff",@"Create Web Service",@"Test Bluno Connection", nil];
    
    
    self.tableView = [self makeTableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Options"];
    [self.view addSubview:self.tableView];
    
    // load array items - TEMP ITEMS TO LOAD IN UIPICKERVIEW
    self.items = [NSArray arrayWithObjects:@"Red",@"Green",@"Blue", nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Option";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // configure the cell
    cell.textLabel.text = [NSString stringWithFormat:[_options objectAtIndex:indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_options count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate

- (void)showViewControllerRootHomeCenter {
    if (self.myDelegate){
        [myDelegate loadVCRH];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    NSString *currentString = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    if ([currentString isEqualToString:@"Logoff"]) {
        NSLog(@"Logout button pressed");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if ([currentString isEqualToString:@"Manage Accounts"]) {
        NSLog(@"Manage Accounts button pressed");
        
        // do any additional checks / loads for managing accounts.
        
        // What is the current view controller? i.e. print current vc
        NSLog(@"The current vc is %@",self);
        
        NSLog(@"The parent vc is %@",self.parentViewController);
        
        [myDelegate loadVCRH];
    }
    
    if ([currentString isEqualToString:@"Add Credits"]) {
        NSLog(@"Add Credits field / button tapped");
        
        NSLog(@"The current vc is %@",self);
        
        NSLog(@"The parent vc is %@",self.parentViewController);
        
        if (self.parentViewController.isViewLoaded)
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:_managedObjectContext];
            [fetchRequest setEntity:entity];
            
            fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"username"]];
            
            NSError *error = nil;
            NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if (error) {
                NSLog(@"Unable to execute fetch request.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            } else {
                NSLog(@"%@", result);
            }
            
            NSMutableArray *names = [NSMutableArray arrayWithCapacity:[result count]];
            for (Account *account in result) {
                NSString *accountName = account.username;
                if (!accountName) {
                    accountName = @"<Unknown Account>";
                }
                [names addObject:accountName];
            }
            
            NSLog(@"load UIPickerView here :)");
            KCModalPickerView *pickerView = [[KCModalPickerView alloc] initWithValues:names];
            
            [pickerView presentInView:self.parentViewController.view withBlock:^(BOOL madeChoice) {
                NSLog(@"Made choice? %d", madeChoice);
            }];
        
        
        [myDelegate loadVCRH];
        }
    }
    
    if ([currentString isEqualToString:@"Change Pin"]) {
        NSLog(@"Change Pin field / cell tapped");
        // load ViewControllerUsers vc.
        AppDelegate *appDelegate = APPDELEGATE;
        UIStoryboard *storyboard = appDelegate.storyboard;
        UIViewController *changePin = [storyboard instantiateViewControllerWithIdentifier:@"users"];
        [self presentViewController:changePin animated:YES completion:nil];
    }
    
    if ([currentString isEqualToString:@"Create Web Service"]) {
        ViewControllerWebService *webServiceVC = [[ViewControllerWebService alloc] initWithNibName:@"ViewControllerWebService" bundle:nil];
        // establish delegate for vc
        webServiceVC.delegate = self;
        [self presentViewController:webServiceVC animated:YES completion:nil];
    }
    
    if ([currentString isEqualToString:@"Test Bluno Connection"]) {
        AppDelegate *appDelegate = APPDELEGATE;
        UIStoryboard *storyboard = appDelegate.storyboard;
        ViewControllerDev2 *blunoTestVC = [storyboard instantiateViewControllerWithIdentifier:@"dev2"];
        [self presentViewController:blunoTestVC animated:YES completion:nil];
    }
}
@end