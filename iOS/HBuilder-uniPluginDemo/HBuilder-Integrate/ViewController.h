//
//  ViewController.h
//  Pandora
//
//  Created by Mac Pro_C on 12-12-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDRCore.h"
#import "PDRCoreAppWindow.h"

@interface ViewController : UIViewController<PDRCoreDelegate,PDRCoreAppWindowDelegate>
{
    IBOutlet UIButton *btnShowLocalPage;
    IBOutlet UIButton *btnShowLocalPage2;
}

-(IBAction)ShowWebViewPageOne:(id)sender;
-(IBAction)ShowWebViewPageTwo:(id)sender;
@end
