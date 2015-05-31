#import "Credits.h"
#import "XLFormSectionDescriptor.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

NSDictionary *email;

@implementation Credits

- (instancetype) initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    if(self)
        [self Initialize];
    
    return self;
    
}

- (instancetype) init {
    
    self = [super init];
    
    if(self)
        [self Initialize];
    
    return self;
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.tableView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0];
    
}

- (void) Initialize {
    
    XLFormDescriptor * form = [XLFormDescriptor formDescriptorWithTitle:@"Credits"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    /* Basic Information */
    section = [XLFormSectionDescriptor formSectionWithTitle:@"                               Ringraziamenti"];
    [form addFormSection:section];
 
    /* Supervisione */
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Supervisore"];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"key" rowType:XLFormRowDescriptorTypeButton title:@"Prof. Emanuele Panizzi"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];
    [form addFormSection:section];
    
    /* User Researchers */
    section = [XLFormSectionDescriptor formSectionWithTitle:@"User-Researchers"];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"key" rowType:XLFormRowDescriptorTypeButton title:@"Vincenzo de Pinto"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"key" rowType:XLFormRowDescriptorTypeButton title:@"Valentina Pizzo"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];
    
    [form addFormSection:section];
    
    /* Developers */
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Sviluppatori"];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"key" rowType:XLFormRowDescriptorTypeButton title:@"Marco Finocchi"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"key" rowType:XLFormRowDescriptorTypeButton title:@"Marco Mulas"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"key" rowType:XLFormRowDescriptorTypeButton title:@"Giulio Salierno"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"key" rowType:XLFormRowDescriptorTypeButton title:@"Lorenzo Spataro"];
    row.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:row];

    [form addFormSection:section];

    /*Version Control*/
    section = [XLFormSectionDescriptor formSectionWithTitle:@""];

    XLFormRowDescriptor *infoRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:@"kInfo" rowType:XLFormRowDescriptorTypeInfo];
    infoRowDescriptor.title = @"Versione";
    infoRowDescriptor.value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [section addFormRow:infoRowDescriptor];
    [form addFormSection:section];
    
    /* Set email */
    [self setEmail];

     self.form = form;
    
}

/* Send Email Method */
- (void) didTouchButton:(XLFormRowDescriptor *)sender {
    
    /* Destinatario */
    NSString *toEmail = [sender title];
    
    /* E-mail del destinatario */
    NSString *destEmail = email[toEmail];
    
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer.mailComposeDelegate self];
        [mailer setSubject:@"RankIT feedback"];
        NSArray *toRecipients = [NSArray arrayWithObjects:destEmail,nil];
        [mailer setToRecipients:toRecipients];
        [self presentModalViewController:mailer animated:YES];
      
    }
    
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errore!"
                                                        message:@"Nessuna email configurata sul tuo dispositivo."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        
    }

    [self deselectFormRow:sender];

}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
            
        case MFMailComposeResultCancelled:
            break;
            
        case MFMailComposeResultSaved:
            break;
            
        case MFMailComposeResultSent:
            break;
            
        case MFMailComposeResultFailed:
            break;
            
        default:
            break;
            
    }
    
    /* Close the Mail Interface */
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

/* Set E-mail Method */
- (void) setEmail {
    
    email = [NSMutableDictionary new];
    
    [email setValue:@"panizzi@di.uniroma1.it" forKey:@"Prof. Emanuele Panizzi"];
    [email setValue:@"depintovincenzo@gmail.com" forKey:@"Vincenzo de Pinto"];
    [email setValue:@"valentinapizzo29@gmail.com" forKey:@"Valentina Pizzo"];
    [email setValue:@"mrcfinocchi@gmail.com" forKey:@"Marco Finocchi"];
    [email setValue:@"mlsmrc@gmail.com" forKey:@"Marco Mulas"];
    [email setValue:@"salierno.g92@gmail.com" forKey:@"Giulio Salierno"];
    [email setValue:@"panizzi@di.uniroma1.it" forKey:@"Lorenzo Spataro"];
    
}

@end