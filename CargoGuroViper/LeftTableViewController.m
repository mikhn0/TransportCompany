//
//  LeftTableViewController.m
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import "LeftTableViewController.h"
#import "RevealTableViewCell.h"
#import "JVFloatingDrawerViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "LanguageViewController.h"
#import "Animator.h"

enum {
    kSearchIndex    = 0,
    kLanguageIndex  = 1,
    kCurrencyIndex  = 2,
    kWeightIndex    = 3,
    kVolumeIndex    = 4,
    kAboutProjectIndex = 5,
    kContactUsIndex = 6
};

static const CGFloat kJVTableViewTopInset = 50.0;
static NSString * const kSearchCellReuseIdentifier = @"SearchCellReuseIdentifier";
static NSString * const kConfigCellReuseIdentifier = @"ConfigCellReuseIdentifier";
static NSString * const kInfoCellReuseIdentifier = @"InfoCellReuseIdentifier";


@interface LeftTableViewController () <RevealTableViewCellDelegate, UIViewControllerTransitioningDelegate >
{
    NSInteger currentCountry;
    NSInteger currentCurrency;
    NSInteger currentWeight;
    NSInteger currentVolume;
    BOOL isFirsty;
}
@property (nonatomic) NSArray *leftMenuSections;
@property (nonatomic) NSArray *configName;

@end

@implementation LeftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirsty = YES;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(kJVTableViewTopInset, 0.0, 0.0, 0.0);
    self.clearsSelectionOnViewWillAppear = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    currentCountry = INDEX_COUNTRY;
    currentCurrency = INDEX_CURRENCY;
    currentVolume = INDEX_VOLUME;
    currentWeight = INDEX_WEIGHT;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguageWithIndexCountry:) name:@"ChangeLanguage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrencyWithIndex:) name:@"ChangeCurrency" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeVolumeWithIndex:) name:@"ChangeVolume" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWeightWithIndex:) name:@"ChangeWeight" object:nil];
    
    
}

- (NSArray *)leftMenuSections {
    return @ [ LocalizedString(@"SEARCH"),LocalizedString(@"LANGUAGE") ,LocalizedString(@"CURRENCY") ,LocalizedString(@"WEIGHT") ,LocalizedString(@"VALUE") ,LocalizedString(@"TITLE_ABOUT") ,LocalizedString(@"FEEDBACK")];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideKeyboard" object:nil];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:kSearchIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (NSArray *)configName {
    return @[CURRENCY_NAME, WEIGHT_NAME, VOLUME_NAME];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case kSearchIndex:
        {
            return 120;
        }
            break;
            
        default:
            return 60;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RevealTableViewCell *cell;
    
    switch (indexPath.row) {
        case kSearchIndex:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kSearchCellReuseIdentifier forIndexPath:indexPath];
            [cell setSearchText:isFirsty];
            isFirsty = NO;
            cell.delegate = self;
        }
            break;
            
        case kLanguageIndex:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kConfigCellReuseIdentifier forIndexPath:indexPath];
            cell.titleText = [self.leftMenuSections objectAtIndex:indexPath.row];
            cell.iconImage = [UIImage imageNamed:[COUNTRY_IMAGE_NAME objectAtIndex:currentCountry]];
            cell.titleParameter = [SHORT_LANGUAGE_NAME objectAtIndex:currentCountry];
        }
            break;
        case kCurrencyIndex:
        case kWeightIndex:
        case kVolumeIndex:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kConfigCellReuseIdentifier forIndexPath:indexPath];
            cell.titleText = [self.leftMenuSections objectAtIndex:indexPath.row];
            cell.iconImage = nil;
            
            cell.titleParameter = [[self.configName objectAtIndex:indexPath.row-2] objectAtIndex:(indexPath.row == kCurrencyIndex ? currentCurrency : indexPath.row == kWeightIndex ? currentWeight : indexPath.row == kVolumeIndex ? currentVolume : 0)];
        }
            break;
        case kAboutProjectIndex:
        case kContactUsIndex:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kInfoCellReuseIdentifier forIndexPath:indexPath];
            cell.titleText = [self.leftMenuSections objectAtIndex:indexPath.row];
        }
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *destinationViewController = nil;

    switch (indexPath.row) {
        case kLanguageIndex:
            destinationViewController = [[AppDelegate globalDelegate] languageViewController];
            
            break;
        case kCurrencyIndex:
            destinationViewController = [[AppDelegate globalDelegate] currencyViewController];
            break;
        case kWeightIndex:
            destinationViewController = [[AppDelegate globalDelegate] weightViewController];
            break;
        case kVolumeIndex:
            destinationViewController = [[AppDelegate globalDelegate] volumeViewController];
            break;
            
        case kAboutProjectIndex:
            destinationViewController = [[AppDelegate globalDelegate] aboutUsViewController];
            break;
        case kContactUsIndex:
            destinationViewController = [[AppDelegate globalDelegate] returnConnectionViewController];
            break;
            
        default:
            break;
    }
    if (indexPath.row != 0) {
        
        destinationViewController.transitioningDelegate = self;
        destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:destinationViewController animated:YES completion:nil];
        
    }
    
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    Animator *animator = [Animator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    Animator *animator = [Animator new];
    return animator;
}


#pragma mark - RevealTableViewCellDelegate

- (void)segueOnMainScreen {
    UINavigationController *destinationViewController = nil;
    destinationViewController = (UINavigationController *)[[AppDelegate globalDelegate] calculateModuleViewController];
    [destinationViewController popToRootViewControllerAnimated:NO];
    [self.mm_drawerController setCenterViewController:destinationViewController withCloseAnimation:YES completion:nil];
}


#pragma mark - LanguageViewControllerDelegate
- (void)changeLanguageWithIndexCountry:(NSNotification *)notification {
    currentCountry = [notification.userInfo[@"indexCountry"] integerValue];
    [self.tableView reloadData];
}

- (void)changeCurrencyWithIndex:(NSNotification *)notification {
    currentCurrency = [notification.userInfo[@"indexCurrency"] integerValue];
    [self.tableView reloadData];
}

- (void)changeVolumeWithIndex:(NSNotification *)notification {
    currentVolume = [notification.userInfo[@"indexVolume"] integerValue];
    [self.tableView reloadData];
}

- (void)changeWeightWithIndex:(NSNotification *)notification {
    currentWeight = [notification.userInfo[@"indexWeight"] integerValue];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Dispose of any resources that can be recreated.
}

@end
