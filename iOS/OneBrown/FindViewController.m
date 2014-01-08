//
//  FindViewController.m
//  OneBrown
//
//  Created by Valentin Perez on 1/6/14.
//  Copyright (c) 2014 Benjamin Murphy. All rights reserved.
//

#import "FindViewController.h"
#import "SignInViewController.h"
#import "UserCell.h"
#import "NetworkManager.h"

@interface FindViewController ()
{
    
    NSUserDefaults *defaults;
    NSMutableArray *userPictures;
    NSMutableArray *userPictureNames;
        
}

@end

@implementation FindViewController

@synthesize manager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
   
    [self.collectionView setDataSource: self];
    [self.collectionView setDelegate: self];
    
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    userPictureNames = [[NSMutableArray alloc]init];
    userPictures = [[NSMutableArray alloc]init];

    userPictureNames = [NSMutableArray arrayWithObjects: @"Valentin Perez", @"Ben Murphy", @"sara", @"joan", @"erik", @"john", nil];
    
    for (NSString *name in userPictureNames)
        [userPictures addObject:[UIImage imageNamed: name]];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated
{
    [defaults setObject:@NO forKey:@"loggedIn"]; //Enable log in screen for testing purposes
    
    // Show the sign up/log in view if the user is not loggedIn
    if(![defaults boolForKey:@"loggedIn"])
    {
        SignInViewController *signIn = [[SignInViewController alloc] init];
        signIn = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInController"];
        [self presentViewController:signIn animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NetworkManager delegate method
/*
 * Called when NetworkManager receives new JSON data
 */
-(void)didReceiveJSON:(NSDictionary *)JSON {
    NSLog(@"%@", JSON);
}

# pragma mark - CollectionView methods.


- (NSInteger) collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [userPictureNames count];
}


/*
 * Return 1 for number of sections.
 */
- (NSInteger) collectionView:(UICollectionView *)view numberOfSection:(NSInteger)section
{
    return 1;
}

/*
 * Displays the cells of the collectionView
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath: indexPath];
    
    // Set the appropiate image and name to it.
    [cell.userImageView setImage: userPictures[indexPath.row]];
    
    [cell.userNameLabel setText: userPictureNames[indexPath.row]];
    
    return cell;
}


/*
 * Handles the cell the user clicked in the collectionView.
 */
- (void) collectionView:(UICollectionView *) cv didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([_searchBar isFirstResponder] && [touch view] != _searchBar)
        [_searchBar resignFirstResponder];
    
}

@end
