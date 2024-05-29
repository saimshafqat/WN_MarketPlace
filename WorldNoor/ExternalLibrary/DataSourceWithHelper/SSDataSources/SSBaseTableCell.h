//
//  SSBaseTableCell.h
//  SSDataSources
//
//  Created by Jonathan Hersh on 1/5/13.
//  Copyright (c) 2013 Jonathan Hersh. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A simple base table cell. Subclass me and override configureCell
 * to add custom one-time logic (e.g. creating subviews).
 * Override cellStyle to use a different style.
 * You probably don't need to override identifier.
 */

@interface SSBaseTableCell : UITableViewCell

// Block called when embeded collection cell is selected.
typedef void (^SSCollectionCellDidSelectBlock) (id object,               // The object being presented in this cell
                                                id parentView,           // The parent table or collection view
                                                NSIndexPath *indexPath); // Index path for this cell

typedef void (^SSRefreshParentTableView) (id object,               // The object being presented in this cell
                                                id parentView,           // The parent table or collection view
                                                NSIndexPath *indexPath); // Index path for this cell

/**
 * Dequeues a table cell from tableView, or if there are no cells of the
 * receiver's type in the queue, creates a new cell and calls -configureCell.
 */
+ (instancetype) cellForTableView:(UITableView *)tableView;

/**
 *  Cell's identifier. You probably don't need to override me.
 *
 *  @return an identifier for this cell class
 */
+ (NSString *) identifier;

/**
 *  Cell style to use. Override me in a subclass and return a different style.
 *
 *  @return cell style to use for this class
 */
+ (UITableViewCellStyle) cellStyle;

/**
 *  Called once for each cell after initial creation.
 *  Subclass me for one-time logic, like creating subviews.
 */
- (void) configureCell;

- (void)configureCell:(id)cell atIndex:(NSIndexPath *)thisIndex withObject:(id)object;

@property (copy, nonatomic) void (^didTapTableButtonBlock)(id sender);
@property (copy, nonatomic) void (^didTapShareButtonBlock)(id sender);

- (void)setDidTapTableButtonBlock:(void (^)(id sender))didTapButtonBlock;
- (void)setDidTapShareButtonBlock:(void (^)(id sender))didTapShareButtonBlock;



/**
 * Cell configuration block, called for each table and collection
 * cell with the object to display in that cell. See block signature above.
 */
@property (nonatomic, copy) SSCollectionCellDidSelectBlock collectionCellDidSelectBlock;

@property (nonatomic, copy) SSRefreshParentTableView refreshParentTableView;

- (IBAction)didTapButton:(id)sender;

@end
