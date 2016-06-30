//
//  CGCalculateModuleViewController.m
//  CargoGuro
//
//  Created by Viktoria on 24/02/2016.
//  Copyright © 2016 Fruktorum. All rights reserved.
//

#import "CGCalculateModuleViewController.h"

#import "CGCalculateModuleViewOutput.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"
#import "VolumeCalculateView.h"

#import "CGCalculateModulePresenter.h"

@interface CGCalculateModuleViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate,  VolumeCalculateViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    GMSPlacesClient *_placesClient;
    NSString *cFC, *cTC, *cFS, *cTS;
}

@property (weak, nonatomic) IBOutlet UIButton *searchTransite;
@property (weak, nonatomic) IBOutlet UIButton *replaceCity;
@property (weak, nonatomic) IBOutlet UIButton *calculateVolume;
@property (weak, nonatomic) IBOutlet UILabel *logoLabel;
@property (weak, nonatomic) IBOutlet UILabel *globalTransInfSysLabel; // глобальная транспортно-информационная система
@property (weak, nonatomic) IBOutlet UILabel *calcLoadDeliveryCoastLabel; //расчитайте стоимость доставки груза

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *from;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *to;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *value;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *weight;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *cost;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *inputView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aligment_from_to;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aligment_to_volume;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aligment_volume_weight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aligment_weight_cost;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aligment_cost_button;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aligment_from_right;

@property (nonatomic) JVFloatLabeledTextField *activeField;

@property (nonatomic) UITableView *autocompleteTableView;
@property (nonatomic) NSMutableArray *autocompleteUrls;
@property (nonatomic) NSArray *pastUrls;

@end


@implementation CGCalculateModuleViewController

#pragma mark - Методы жизненного цикла

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.logoLabel.adjustsFontSizeToFitWidth = YES;
    _placesClient = [[GMSPlacesClient alloc] init];
    self.autocompleteUrls = [NSMutableArray array];
    [self addAutocomplitedTableForTextField];
    
    UIColor *borderColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    self.from.delegate = self;
    self.from.layer.borderWidth = 0.5;
    self.from.layer.borderColor = borderColor.CGColor;
    self.from.layer.cornerRadius = 3.0;
    
    self.to.delegate = self;
    self.to.layer.borderWidth = 0.5;
    self.to.layer.borderColor = borderColor.CGColor;
    self.to.layer.cornerRadius = 3.0;
    
    self.value.delegate = self;
    self.value.layer.borderWidth = 0.5;
    self.value.layer.borderColor = borderColor.CGColor;
    self.value.layer.cornerRadius = 3.0;
    
    self.weight.delegate = self;
    self.weight.layer.borderWidth = 0.5;
    self.weight.layer.borderColor = borderColor.CGColor;
    self.weight.layer.cornerRadius = 3.0;
    
    self.cost.delegate = self;
    self.cost.layer.borderWidth = 0.5;
    self.cost.layer.borderColor = borderColor.CGColor;
    self.cost.layer.cornerRadius = 3.0;
    

    self.searchTransite.layer.cornerRadius = 5.0;
    self.searchTransite.enabled = NO;
    self.searchTransite.alpha = 0.5;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.delegate = self;
    [self.scrollView addGestureRecognizer:tapGesture];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    [self registerForKeyboardNotifications];
    
    self.aligment_from_to.constant = (14 * self.view.frame.size.width) / 305.0;
    self.aligment_to_volume.constant = (14 * self.view.frame.size.width) / 305.0;
    self.aligment_volume_weight.constant = (14 * self.view.frame.size.width) / 305.0;
    self.aligment_weight_cost.constant = (14 * self.view.frame.size.width) / 305.0;
    self.aligment_cost_button.constant = (14 * self.view.frame.size.width) / 305.0;
    self.aligment_from_right.constant = (20 * self.view.frame.size.width) / 305.0;

    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIColor *colorText = [UIColor whiteColor];
 
    self.globalTransInfSysLabel.text = LocalizedString(@"GLOBAL_TRANSPORT_INFORMATION_SYSTEM");
    self.calcLoadDeliveryCoastLabel.text = LocalizedString(@"CALCULATE_LOAD_DELIVERY_COAST");
    
    self.from.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LocalizedString(@"ENTER_FROM") attributes:@{NSForegroundColorAttributeName: colorText}];
    
    self.to.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LocalizedString(@"ENTER_TO") attributes:@{NSForegroundColorAttributeName: colorText}];
    
    self.value.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)",LocalizedString(@"ENTER_VALUE"),  [NSString printCubeOfValue:LocalizedString(@"M")]] attributes:@{NSForegroundColorAttributeName: colorText}];
    
    self.weight.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)",LocalizedString(@"ENTER_WEIGHT"),  LocalizedString(@"KG")] attributes:@{NSForegroundColorAttributeName: colorText}];
    
    self.cost.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", LocalizedString(@"ENTER_DECLARED_VALUE"), LocalizedString(@"CURENCY_VALUE")] attributes:@{NSForegroundColorAttributeName: colorText}];
    
    [self.searchTransite setTitle:LocalizedString(@"ENTER_CALCULATE") forState:UIControlStateNormal];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)addAutocomplitedTableForTextField {
    CGFloat widthComplTable = self.inputView.frame.size.width;
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:
                             CGRectMake(0, 0, widthComplTable, 190.0) style:UITableViewStylePlain];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    self.autocompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.inputView addSubview:self.autocompleteTableView];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Actions

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - Helpers

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    return [[AppDelegate globalDelegate] drawerAnimator];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //Autocomplited Textfield - START
    if (textField.tag == 1 || textField.tag == 2) {
        self.autocompleteTableView.hidden = NO;
        CGRect frameTable = self.autocompleteTableView.frame;
        frameTable.origin = CGPointMake(self.activeField.frame.origin.x, self.activeField.frame.origin.y + self.activeField.frame.size.height+2);
        frameTable.size.width = self.activeField.frame.size.width;
        self.autocompleteTableView.frame = frameTable;
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring
                     stringByReplacingCharactersInRange:range withString:string];
        [self placeAutocomplete:substring];
        
        
        
        CGRect tfRect = self.activeField.frame;
        tfRect.origin.y += self.autocompleteTableView.frame.size.height + 45.0;
        [self.scrollView scrollRectToVisible:tfRect animated:YES];
        //self.scrollView.canCancelContentTouches = NO;

    }
    
    //Autocomplited Textfield - END
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        if (textField == self.value || textField == self.weight || textField == self.cost) {
            NSString *candidate = [[textField text] stringByReplacingCharactersInRange:range withString:string];
            if (!candidate || [candidate length] < 1 || [candidate isEqualToString:@""])
            {
                return YES;
            }
            if (candidate && [candidate length] > 1 && [[candidate substringFromIndex:[candidate length] - 1] isEqualToString:@","] && [[textField text] rangeOfString:@","].location == NSNotFound)
            {
                return YES;
            }
            NSScanner *scanner = [NSScanner scannerWithString:string];
            BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
            if (isNumeric) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return YES;
}


- (void)textFieldDidBeginEditing:(JVFloatLabeledTextField *)textField
{
    self.activeField = textField;
    self.activeField.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.from.text.length > 0 && self.to.text.length > 0 && self.value.text.length>0 && self.weight.text.length>0 && self.cost.text.length>0) {
        self.searchTransite.enabled = YES;
        self.searchTransite.alpha = 1.0;
    } else {
        self.searchTransite.enabled = NO;
        self.searchTransite.alpha = 0.5;
    }
    
    self.activeField.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    self.activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    self.autocompleteTableView.hidden = YES;
    return YES;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    CGRect tfRect = self.activeField.frame;
    tfRect.origin.y += self.inputView.frame.origin.y + self.scrollView.frame.origin.y + 64 + self.activeField.frame.size.height;
    
    if (!CGRectContainsPoint(aRect, tfRect.origin) ) {
        tfRect.origin.y -= self.inputView.frame.origin.y + 64 + self.activeField.frame.size.height;
        [self.scrollView scrollRectToVisible:tfRect animated:YES];
    }
}

- (void)hideKeyboard {
    self.autocompleteTableView.hidden = YES;
    [self.from resignFirstResponder];
    [self.to resignFirstResponder];
    [self.value resignFirstResponder];
    [self.weight resignFirstResponder];
    [self.cost resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the segmented control.
    if ([touch.view.superview isKindOfClass:[UITableViewCell class]]) {//change it to your condition
        return NO;
    }
    return YES;
}

#pragma mark - Autocomplited Textfield

- (void)placeAutocomplete:(NSString *)substring {
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterCity;
    
    [_placesClient autocompleteQuery:substring  //this should be your textfield text
                              bounds:nil
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@' with placeID %@", result.attributedPrimaryText.string, result.placeID);
                                }
                                
                                [self.autocompleteUrls removeAllObjects];
                                for (GMSAutocompletePrediction *curString in results) {
                                    
                                    [self.autocompleteUrls addObject:curString];//.attributedPrimaryText.string];
                                    
                                }
                                [self.autocompleteTableView reloadData];
                            }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.autocompleteUrls.count > 0 ? (self.autocompleteUrls.count > 5 ? 6 : self.autocompleteUrls.count+1) : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    NSInteger max = self.autocompleteUrls.count > 4 ? 5 : self.autocompleteUrls.count;
    if (indexPath.row == max) {
        cell.imageView.image = [UIImage imageNamed:@"google"];
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        cell.userInteractionEnabled = NO;
    } else {
        
        NSDictionary* attributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:10]
                                     };
        GMSAutocompletePrediction *curString = self.autocompleteUrls[indexPath.row];
        NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:curString.attributedFullText.string attributes:attributes];
        cell.textLabel.attributedText = attrText;
        [cell.textLabel setNumberOfLines:0];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.userInteractionEnabled = YES;
        
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger max = self.autocompleteUrls.count > 4 ? 5 : self.autocompleteUrls.count;
    if (indexPath.row == max) {
        return 10.0;
    } else {
        return 36.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GMSAutocompletePrediction *curString = self.autocompleteUrls[indexPath.row];
    self.activeField.text = curString.attributedPrimaryText.string;
    
    [[GMSPlacesClient sharedClient] lookUpPlaceID:curString.placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        //    if (self.activeField.tag == 0) {
        //        cFC = curString;
        //        cFS = curString;
        //    } else if (self.activeField.tag == 1) {
        //        cTC = curString;
        //        cTS = curString;
        //    }
        //
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
        
            NSLog(@"Place name %@", result.name);
            NSLog(@"Place address %@", result.formattedAddress);
            NSLog(@"Place placeID %@", result.placeID);
            //GMSAddressComponent *addComponent = result.addressComponents[0];
            //NSLog(@"Address compoent ========= %@", addComponent);
            NSLog(@"Place attributions %@", result.attributions);

    }];

    
    [self hideKeyboard];
}

- (IBAction)changeCityPlaces:(id)sender {
    NSString *fromString = self.from.text;
    self.from.text = self.to.text;
    self.to.text = fromString;
}

- (IBAction)volumeCalculation:(id)sender {
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"VolumeCalculateView" owner:self options:nil];
    VolumeCalculateView *mainView = [subviewArray objectAtIndex:0];
    mainView.delegate = self;
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    // set frame of auto play bg view
    mainView.frame = window.frame;
    [window addSubview: mainView];
}

- (IBAction)searchTransiteAction:(id)sender {
    NSInteger tNum = 1;
    NSString *cargoFrom = self.from.text;
    NSString *cargoTo = self.to.text;
    NSString *cW = self.weight.text;
    NSString *cV = self.value.text;
    NSString *cInsP = self.cost.text;
    
    if (cargoFrom.length < 1) {
        
        [self outPutError:LocalizedString(@"ENTER_ERROR_FROM")];
        
    } else if (cargoTo.length < 1) {
        
        [self outPutError:LocalizedString(@"ENTER_ERROR_TO")];
        
    } else if (self.value.text.length < 1) {
        
        [self outPutError:LocalizedString(@"ENTER_ERROR_VALUE")];
        
    } else if (self.weight.text.length < 1) {
        
        [self outPutError:LocalizedString(@"ENTER_ERROR_WAIST")];
       
    } else {
        NSDictionary *datas = @{@"tNum":@(tNum), @"cargoFrom": cargoFrom, @"cargoTo": cargoTo, @"cW": cW, @"cV": cV, @"cInsP": cInsP, @"lang":@"ru", @"currency": [CURRENCY_NAME objectAtIndex:INDEX_COUNTRY], @"cFC":@"", @"cTC":@"", @"cFS":@"" , @"cTS":@""};//cFC , @"cTC":cTC, @"cFS":cFS , @"cTS":cTS};
        [self.output searchTransition:datas];
        
    }
    
}


#pragma mark - VolumeCalculateViewDelegate 

- (void)resultCalculateVolume:(NSString *)resultString {
    self.value.text = resultString;
}

- (void)outPutError:(NSString *)error {
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alertError = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
    [alertError addAction:alertAction];
    [self presentViewController:alertError animated:YES completion:nil];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
