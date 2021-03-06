#import "ViewControllerAddPoll.h"
#import "XLFormImageSelectorCell.h"
#import "XLFormSectionDescriptor.h"
#import "Font.h"

/* Tag riconoscimento row Nome Poll */
NSString *const kPollName = @"kPollName";

/* Tag riconoscimento row Descrizione Poll */
NSString *const kPollDesc = @"kPollDesc";

/* Tag riconoscimento row visibilità Poll */
NSString *const kPollPrivate = @"kPrivate";

/* Tag riconoscimento row scadenza */
NSString *const kPollDeadLine = @"kPollDeadLine";

/* Tag riconoscimento row candidates */
NSString *const kPollCandidates = @"textFieldRow";

/* Section contenente i candidates */
XLFormSectionDescriptor *multivaluedSection;

@implementation ViewControllerAddPoll

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

- (id) Initialize {
    
    formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Text Fields"];
    form = [XLFormDescriptor formDescriptorWithTitle:@"Sondaggio"];
    
    /* First section */
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    /* Image Poll Row */
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"" rowType:XLFormImageSelectorCellCustom];
    [section addFormRow:row];
    
    /* Aggiunto alla root section */
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    /* Nome Poll Row */
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPollName rowType:XLFormRowDescriptorTypeText];
    [row.cellConfigAtConfigure setObject:@"Titolo (obbligatorio)" forKey:@"textField.placeholder"];
    row.required = YES;
    
    /* Binding regex validazione input (1-21 caratteri) */
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"" regex:@".{1,}$"]];
    [section addFormRow:row];
    
    /* Aggiunto alla root section */
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    /* Terza Row Descrizione Poll */
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPollDesc rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"Descrizione" forKey:@"textView.placeholder"];

    [section addFormRow:row];
    
    /* Scadenza Poll Row */
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPollDeadLine rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Scadenza"];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [row.cellConfigAtConfigure setObject:[NSDate new] forKey:@"minimumDate"];
    [section addFormRow:row];
    
    /* isPrivate */
    row = [XLFormRowDescriptor  formRowDescriptorWithTag:kPollPrivate rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Privato"];
    [section addFormRow:row];
    section.footerTitle =@"Nota: Se il sondaggio è privato non sarà visibile sulla Home di RankIT.";
    
    /* Sezione dedicata all'aggiunta di candidates dinamica */
    multivaluedSection = [XLFormSectionDescriptor  formSectionWithTitle:@"Candidati (Minimo 3)"
                                             sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert | XLFormSectionOptionCanDelete
                                             sectionInsertMode:XLFormSectionInsertModeButton];
    
    multivaluedSection.multivaluedAddButton.title = @"Aggiungi un candidato";
    
    /* Set up the row template */
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPollCandidates rowType:XLFormRowDescriptorTypeText];

    [[row cellConfig] setObject:@"Candidato" forKey:@"textField.placeholder"];

    multivaluedSection.multivaluedTag = @"textFieldRow";
    
    multivaluedSection.multivaluedRowTemplate = row;
    [form addFormSection:multivaluedSection];
    
    self.form = form;
    
    return [super initWithForm:form];

}

/* Override dell'handler per la gestione della aggiunta delle righe rappresentanti candidates imponendo vincoli */
- (void) formRowHasBeenAdded:(XLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath {
    
    [formRow addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"At least 1, max 21 characters" regex:@".{1,21}$"]];
    [super formRowHasBeenAdded:formRow atIndexPath:indexPath];
    
    /* Se abbiamo aggiunto 5 candidati disabilitiamo l'add */
    if(multivaluedSection.formRows.count > 5) {
        
        /* Change properties */
        multivaluedSection.multivaluedAddButton.title = @"Candidati Completati";
        multivaluedSection.multivaluedAddButton.disabled=@YES;
      
        /* refresh view */;
        [super reloadFormRow:multivaluedSection.multivaluedAddButton ];
    
    }
    
}

/* Override per il ripristino dell'add candidates in caso di eliminazione row */
- (void) formRowHasBeenRemoved:(XLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath {
    
    [super formRowHasBeenRemoved:formRow atIndexPath:indexPath];

    /* Se il numero di candidati è < 5 riabilitiamo l'add */
    if(multivaluedSection.formRows.count < 6) {
        
        /* Changing properties */
        multivaluedSection.multivaluedAddButton.title = @"Aggiungi un candidato";
        multivaluedSection.multivaluedAddButton.disabled=@NO;
        
        /* refresh view */;
        [super reloadFormRow:multivaluedSection.multivaluedAddButton];
        
    }
    
}

/* Utilizzata per validare l'input inserito dall'utente */
- (BOOL) validateForm {
    
    __block BOOL isValidName = true;
    __block BOOL isValidDesc = true;
    
    NSArray *array = [self formValidationErrors];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
        
        if([validationStatus.rowDescriptor.tag isEqualToString:kPollName]) {
            
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            cell.backgroundColor = [UIColor redColor];
            
            [UIView animateWithDuration:.3 animations:^{
                
                cell.backgroundColor = [UIColor whiteColor];
                
            }];
            
            isValidName = false;
            [self animateCell:cell];
        
        }
    
    }];
    
    return (isValidName && isValidDesc ? true : false);
    
}

- (void) animateCell:(UITableViewCell *)cell {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values =  @[ @0, @20, @-20, @10, @0];
    animation.keyTimes = @[@0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1];
    animation.duration = .3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.additive = YES;
    [cell.layer addAnimation:animation forKey:@"shake"];
    
}

/* Il metodo si occupa di estrarre i dati dal form */
- (NSMutableDictionary *) getFormValues {
    
    _result = [NSMutableDictionary dictionary];

    for(XLFormSectionDescriptor *section in self.form.formSections) {
        
        if(!section.isMultivaluedSection) {
            
            for(XLFormRowDescriptor *row in section.formRows) {
                
                if(row.tag && ![row.tag isEqualToString:@""])
                    [_result setObject:(row.value ?: [NSNull null]) forKey:row.tag];
            
            }
            
        }
        
        else {
            
            NSMutableArray *multiValuedValuesArray = [NSMutableArray new];
            
            for(XLFormRowDescriptor *row in section.formRows) {
                
                if(row.value)
                    [multiValuedValuesArray addObject:row.value];
    
            }
            
            [_result setObject:multiValuedValuesArray forKey:section.multivaluedTag];
        
        }
        
    }
    
    return _result;

}

/* Il metodo si occupa di restituire il numero di candidates inseriti dall'utente */
- (int) getCandidatesSize {
    
    int candidateCount = 0;
    
    for(XLFormSectionDescriptor *section in self.form.formSections) {
        
        /* Se è la section dedicata all'aggiunta dei candidates */
        if(section.isMultivaluedSection) {
            
            for(XLFormRowDescriptor *row in section.formRows) {
                
                if(row.value)
                    candidateCount++;
            
            }
        
        }
        
    }
    
    return candidateCount;

}

- (void) viewDidLoad{
    
    [super viewDidLoad];

}

- (void) viewDidAppear:(BOOL)animated {
    
    [self.tableView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0];
    
}

/* Previene l'hide della keyboard sullo swipe */
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    

}

- (UIView *) inputAccessoryViewForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    
    return nil;
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:(@"summary")]) {
            
        [self getFormValues];
        ViewControllerSummaryPoll *vc = (ViewControllerSummaryPoll*) [segue destinationViewController ];
        vc.summaryResult = _result;
        vc.isModified = false;
        
    }
    
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if([identifier isEqualToString:@"summary"] && [self validateForm] && [self getCandidatesSize] > 2) {
        
        return YES;
        
    }
    
    else {
        
        [self WrongInputAlert];
        return NO;
        
    }
    
    return NO;

}

/* Alert Box input errato */
- (void) WrongInputAlert {
    
    UIAlertController *AlertWrongInput = [UIAlertController alertControllerWithTitle:@"Attenzione" message:@"Non stai rispettando i parametri di input richiesti!" preferredStyle:UIAlertControllerStyleActionSheet];
    
    /* Uscita dell'alert */
    [self presentViewController:AlertWrongInput animated:YES completion:nil];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        /* Rientro dell'alert */
        [AlertWrongInput dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [AlertWrongInput addAction:ok];
    [self.tableView reloadData];
    
}

@end