//
//  LanguageViewController.m
//  CargoGuruViper
//
//  Created by a1 on 01.06.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanTableViewCell.h"

enum {
    kRus  = 0,
    kChn  = 1,
    kEng  = 2,
    kDeu  = 3
};


static NSString * const kLanCellReuseIdentifier = @"LanCellReuseIdentifier";

@implementation LanguageViewController

@synthesize countryName = _countryName;
@synthesize countryImageName = _countryImageName;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentIndexCountry"] integerValue];
}

- (NSArray *)countryName {
    return @[@"Русский", @"中国人", @"English", @"Deutsch"];
}

- (NSArray *)countryImageName {
    return @[@"rus_flag", @"ch_flag", @"en_flag", @"en_flag"];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_countryName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLanCellReuseIdentifier forIndexPath:indexPath];
    cell.name = [self.countryName objectAtIndex:indexPath.row];
    cell.imageByName = [UIImage imageNamed:[self.countryImageName objectAtIndex:indexPath.row]];
    
    [[cell selectedIcon] setHidden:YES];
    if (indexPath.row == self.currentIndex) {
        [[cell selectedIcon] setHidden:NO];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Выбор языка";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndex = indexPath.row;
    [self.tableView reloadData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(indexPath.row) forKey:@"currentIndexCountry"];
    [defaults synchronize];
    
    NSDictionary *userInfo = @{@"indexCountry":@(indexPath.row)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeLanguage" object:nil userInfo:userInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
