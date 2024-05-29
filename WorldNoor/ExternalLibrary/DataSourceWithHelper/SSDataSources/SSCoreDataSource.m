//
//  SSCoreDataSource.m
//  SSDataSources
//
//  Created by Jonathan Hersh on 6/7/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "SSDataSources.h"
#import "UICollectionView+NSFetchedResultsController.h"
#import "UITableView+NSFetchedResultsController.h"

@interface SSCoreDataSource ()

// For UICollectionView

@property (nonatomic, copy) SSResultsFilter *lastFilter;

- (void) _performFetch;

@end

@implementation SSCoreDataSource

- (instancetype)init {
    if ((self = [super init])) {
    }
    
    return self;
}

- (instancetype) initWithFetchedResultsController:(NSFetchedResultsController *)aController {
    if ((self = [self init])) {
        _controller = aController;
        self.controller.delegate = self;
        
        if (!self.controller.fetchedObjects) {
            [self _performFetch];
        }
    }
    
    return self;
}

- (void)updateController:(NSFetchedResultsController *)aController {
    if (!aController.fetchedObjects) {
        self.controller = aController;
        self.controller.delegate = self;
        [self _performFetch];
    }
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)request
                           inContext:(NSManagedObjectContext *)context
                  sectionNameKeyPath:(NSString *)sectionNameKeyPath {
    
    return [self initWithFetchedResultsController:
            [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                managedObjectContext:context
                                                  sectionNameKeyPath:sectionNameKeyPath
                                                           cacheName:nil]];
}

- (void)dealloc {
    self.controller.delegate = nil;
    self.controller = nil;
    self.coreDataMoveRowBlock = nil;
    self.titleForHeaderConfigureBlock = nil;
}

#pragma mark - Fetching

- (void)_performFetch {
    NSError *fetchErr;
    [self.controller performFetch:&fetchErr];
    _fetchError = fetchErr;
}

#pragma mark - SSDataSourceItemAccess

- (NSUInteger)numberOfSections {
    return (self.currentFilter
            ? [self.currentFilter numberOfSections]
            : (NSUInteger)[[self.controller sections] count]);
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    if (self.currentFilter) {
        return [self.currentFilter numberOfItemsInSection:section];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.controller sections][(NSUInteger)section];
    return (NSUInteger)[sectionInfo numberOfObjects];
}

- (NSUInteger)numberOfItems {
    if (self.currentFilter) {
        return [self.currentFilter numberOfItems];
    }
    
    NSUInteger count = 0;
    
    for (id <NSFetchedResultsSectionInfo> section in [self.controller sections])
        count += [section numberOfObjects];
    
    return count;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentFilter) {
        return [self.currentFilter itemAtIndexPath:indexPath];
    }
    id  result  = nil;
    if ([[self.controller sections] count] > [indexPath section]){
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.controller sections] objectAtIndex:[indexPath section]];
        if ([sectionInfo numberOfObjects] > [indexPath row]){
            result = [self.controller objectAtIndexPath:indexPath];
        }
    }
    
    return result;
}

#pragma mark - Core Data access

- (NSIndexPath *)indexPathForItemWithId:(NSManagedObjectID *)objectId {
    for (NSUInteger section = 0; section < [self numberOfSections]; section++) {
        id <NSFetchedResultsSectionInfo> sec = [self.controller sections][section];
        
        NSUInteger index = [[sec objects] indexOfObjectPassingTest:^BOOL(NSManagedObject *object,
                                                                         NSUInteger idx,
                                                                         BOOL *stop) {
            return [[object objectID] isEqual:objectId];
        }];
        
        if (index != NSNotFound) {
            return [NSIndexPath indexPathForRow:(NSInteger)index inSection:(NSInteger)section];
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.controller sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.sectionIndexTitlesConfigureBlock) {
        return self.sectionIndexTitlesConfigureBlock(self.controller, tableView);
    }
    else    {
        return [self.controller sectionIndexTitles];
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.controller sections][(NSUInteger)section];
    if (self.titleForHeaderConfigureBlock) {
        return self.titleForHeaderConfigureBlock(sectionInfo, self.collectionView,
                                                 section);
    }
    else    {
        return [sectionInfo name];
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    id item = [self itemAtIndexPath:sourceIndexPath];
    
    if (self.coreDataMoveRowBlock) {
        self.coreDataMoveRowBlock(item, sourceIndexPath, destinationIndexPath);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    
    [self.tableView commitChanges:^(id success) {
        if (self.lastFilter) {
            [self setCurrentFilter:self.lastFilter];
            self.lastFilter = nil;
        }
        // Hackish; force recalculation of empty view state
        self.emptyView = self.emptyView;
        if (self.coreDataPostReloadBlock) {
            self.coreDataPostReloadBlock(self, self.tableView);
        }
    }];
    
    [self.collectionView commitChanges:^(id success) {
        if (self.lastFilter) {
            [self setCurrentFilter:self.lastFilter];
            self.lastFilter = nil;
        }
        // Hackish; force recalculation of empty view state
        self.emptyView = self.emptyView;
        if (self.coreDataPostReloadBlock) {
            self.coreDataPostReloadBlock(self, self.collectionView);
        }
    }];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _lastFilter = (self.currentFilter ?: nil);
    [self setCurrentFilter:nil];
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    [self.collectionView addChangeForObjectAtIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:self.rowAnimation];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:self.rowAnimation];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:self.rowAnimation];
            break;
            
        case NSFetchedResultsChangeMove:
        {
            [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:self.rowAnimation];
            [tableView insertRowsAtIndexPaths:@[ newIndexPath ]
                             withRowAnimation:self.rowAnimation];
            break;
        }
    }
    
    
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    UITableView *tableView = self.tableView;
    [self.collectionView addChangeForSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:self.rowAnimation];
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:self.rowAnimation];
            break;
        default:
            return;
    }
}

@end

