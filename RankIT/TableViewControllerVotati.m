#import "TableViewControllerVotati.h"
#import "TableViewControllerResults.h"
#import "ViewControllerDettagli.h"
#import "ConnectionToServer.h"
#import "APIurls.h"
#import "Font.h"
#import "File.h"
#import "Util.h"

@interface UIViewController ()

@end

@implementation TableViewControllerVotati {
    
    /* Oggetto per la connessione al server */
    ConnectionToServer *Connection;
    
    /* Dizionario dei poll votati */
    NSMutableDictionary *allVotedPolls;
    
    /* Array dei poll votati che verranno visualizzati */
    NSMutableArray *allVotedPollsDetails;
    
    /* Array per i risultati di ricerca */
    NSArray *searchResults;
    
    /* Variabile che conterrà la subview da rimuovere */
    UIView *subView;
    
    /* Messaggio nella schermata Votati */
    UILabel *messageLabel;
    
    /* Pulsante di ritorno schermata precedente */
    UIBarButtonItem *backButton;
    
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    /* Setta la spaziatura per i voti corretta per ogni IPhone */
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    if(screenWidth == IPHONE_6_WIDTH)
        X_FOR_VOTES = IPHONE_6;
    
    else {
        
        if(screenWidth == IPHONE_6Plus_WIDTH)
            X_FOR_VOTES = IPHONE_6Plus;
        
        else
            X_FOR_VOTES = IPHONE_4_4S_5_5S;
        
    }
    
    /* Permette alle table view di non stampare celle vuote che vanno oltre quelle dei risultati */
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    /* Download iniziale di tutti i poll votati */
    [self DownloadPolls];
    
    /* Se non c'è connessione o non ci sono poll votati, il background della TableView è senza linee */
    if(allVotedPolls==nil || [allVotedPolls count]==0)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    /* Altrimenti prende i nomi dei poll votati da visualizzare */
    else [self CreatePollsDetails];
    
    searchResults = [[NSArray alloc]init];
    
    /* Dichiarazione della label da mostrare in caso di non connessione o assenza di poll */
    messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    messageLabel.font = [UIFont fontWithName:FONT_HOME size:20];
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.tag = 1;
    [messageLabel setFrame:CGRectOffset(messageLabel.bounds, CGRectGetMidX(self.view.frame) - CGRectGetWidth(self.view.bounds)/2, CGRectGetMidY(self.view.frame) - CGRectGetHeight(self.view.bounds)/1.3)];
    
    
    /* Visualizza i poll votati nella schermata "Votati" */
    [self VotedPolls];
    
}

/* Download poll votati dal server */
- (void) DownloadPolls {
    
    Connection = [[ConnectionToServer alloc]init];
    allVotedPolls = [Connection getDizionarioPollsVotati];
    
    if(allVotedPolls!=nil && [allVotedPolls count] != 0)
    {
        [self CreatePollsDetails];
        [self.tableView reloadData];
    }
    
    [self VotedPolls];
    
}

/* Estrapolazione dei dettagli dei poll votati ritornati dal server */
- (void) CreatePollsDetails {
    
    NSString *value;
    allVotedPollsDetails = [[NSMutableArray alloc]init];
    
    /* Scorre il dizionario e recupera i dettagli necessari */
    for(id key in allVotedPolls) {
        
        value = [allVotedPolls objectForKey:key];
        
        Poll *p = [[Poll alloc]initPollWithPollID:[[value valueForKey:@"pollid"] intValue]
                                         withName:[value valueForKey:@"pollname"]
                                  withDescription:[value valueForKey:@"polldescription"]
                                  withResultsType:([[value valueForKey:@"results"] isEqual:@"full"]? 1:0 )
                                     withDeadline:[value valueForKey:@"deadline"]
                                   withLastUpdate:[value valueForKey:@"updated"]
                                   withCandidates:nil
                                        withVotes:(int)[[value valueForKey:@"votes"] integerValue]];
        
        [allVotedPollsDetails addObject:p];
        
    }
    
}

/* Visualizzazione poll votati nella schermata "Votati" */
- (void) VotedPolls {
    
    if(allVotedPolls!=nil) {
        
        if([allVotedPolls count] != 0) {
            
            /* Rimuoviamo la subview aggiunta per il messaggio d'errore */
            subView  = [self.tableView viewWithTag:1];
            [subView removeFromSuperview];
            
            /* Background con linee */
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
        }
        
        else {
            
            /* Rimuove tutte le celle dei poll per mostrare il messaggio di assenza poll */
            [allVotedPollsDetails removeAllObjects];
            [self.tableView reloadData];
            
            /* Stampa del messaggio di notifica */
            [self printMessaggeError];
            
        }
        
    }
    
    /* Internet assente */
    else {
        
        /* Rimuove tutte le celle dei poll per mostrare il messaggio di assenza connessione */
        [allVotedPollsDetails removeAllObjects];
        [self.tableView reloadData];
        
        /* Stampa del messaggio di notifica */
        [self printMessaggeError];
        
    }
    
}

/* Funzione per la visualizzazione del messaggio di notifica di assenza connessione o assenza poll votati */
- (void) printMessaggeError {
    
    /* Background senza linee e definizione del messaggio di assenza poll votati o assenza connessione */
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    /* Assegna il messaggio a seconda dei casi */
    if(allVotedPolls!=nil)
        messageLabel.text = EMPTY_VOTED_POLLS_LIST;
    
    else messageLabel.text = SERVER_UNREACHABLE;
    
    /* Aggiunge la SubView con il messaggio da visualizzare */
    [self.tableView addSubview:messageLabel];
    [self.tableView sendSubviewToBack:messageLabel];
    
}

/* Permette di modificare l'altezza delle righe della schermata "Votati" */
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELL_HEIGHT;
    
}

/* Funzioni che permettono di visualizzare i nomi dei poll votati nelle celle della schermata "Votati" o nei risultati di ricerca */
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        if([searchResults count] == 0) {
            
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
            
            for(UIView *view in self.searchDisplayController.searchResultsTableView.subviews) {
                
                if([view isKindOfClass:[UILabel class]]) {
                    
                    ((UILabel *)view).font = [UIFont fontWithName:FONT_HOME size:20];
                    ((UILabel *)view).textColor = [UIColor darkGrayColor];
                    ((UILabel *)view).text = NO_RESULTS;
                    
                }
            
            }
            
        }
        
        else [self.searchDisplayController.searchResultsTableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
        
        return [searchResults count];
        
    }
    
    else return [allVotedPollsDetails count];
    
}
/* Funzioni che permettono di accedere alla descrizione di un determinato poll sia dalla Home che dai risultati di ricerca */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"showVotedResults"]) {
        
        NSIndexPath *indexPath = nil;
        Poll *p = nil;
        
        if(self.searchDisplayController.active) {
            
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            p = [searchResults objectAtIndex:indexPath.row];
            backButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(SEARCH,returnbuttontitle) style: UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = backButton;
            
            
        }
        
        else {
            
            indexPath = [self.tableView indexPathForSelectedRow];
            p = [allVotedPollsDetails objectAtIndex:indexPath.row];
            backButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(BACK,returnbuttontitle) style: UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = backButton;
            
        }
        
        /* Risultato di tipo short */
        //if(p.resultsType==0) {
        
            TableViewControllerResults *destViewController = (TableViewControllerResults*)segue.destinationViewController;
            destViewController.poll = p;
            destViewController.flussoFrom = FROM_VOTATI;
            backButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(BACK_TO_VOTED,returnbuttontitle) style: UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = backButton;
        
        //}
        
    }
    
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"VotedPollCell";
    Poll *p;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        p = [searchResults objectAtIndex:indexPath.row];
        
    }
    
    else
        p = [allVotedPollsDetails objectAtIndex:indexPath.row];
    
    /* Visualizzazione del poll nella cella */
    UILabel *NamePoll = (UILabel *)[cell viewWithTag:101];
    NamePoll.text = p.pollName;
    NamePoll.font = [UIFont fontWithName:FONT_HOME size:18];
    
    UILabel *DeadlinePoll = (UILabel *)[cell viewWithTag:102];
    DeadlinePoll.text = [Util toStringUserFriendlyDate:(NSString *)p.deadline];
    DeadlinePoll.font = [UIFont fontWithName:FONT_HOME size:12];
    
    UILabel *VotiPoll = (UILabel *)[cell viewWithTag:103];
    VotiPoll.text = [NSString stringWithFormat:@"Voti: %d",p.votes];
    VotiPoll.font = [UIFont fontWithName:FONT_HOME size:12];
    
    /* Muovo la posizione dei voti a seconda del telefono */
    CGRect newPosition = VotiPoll.frame;
    newPosition.origin.x= X_FOR_VOTES;
    VotiPoll.frame = newPosition;
    
    return cell;
    
}

- (void) filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"pollName CONTAINS[c] %@",searchText];
    searchResults = [allVotedPollsDetails filteredArrayUsingPredicate:resultPredicate];
    
}

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
    
}

/* Metodo che fa apparire momentaneamente la scroll bar per far capire all'utente che il contenuto è scrollabile */
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.tableView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0];
    
}

/* Metodo che gestisce il ri-carimento dell view */
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    /* Eliminazione della classifica salvata al momento del passaggio da vota poll a dettagli poll */
    [File clearSaveRank];
    
    /* Deseleziona l'ultima cella cliccata ogni volta che riappare la view */
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    
    /* Ogni volta che la view appare vengono scaricati i poll votati */
    [self DownloadPolls];
    
}

/* Funzioni utili ad una corretta visualizzazione della table view e della search bar */
- (void) searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];

}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        CGRect statusBarFrame =  [[UIApplication sharedApplication] statusBarFrame];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            for(UIView *subview in self.view.subviews)
                subview.transform = CGAffineTransformMakeTranslation(0,statusBarFrame.size.height);
        
        }];
    
    }
    
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        [UIView animateWithDuration:0.25 animations:^{
            
            for(UIView *subview in self.view.subviews)
                subview.transform = CGAffineTransformIdentity;
            
        }];
        
    }
    
}

@end