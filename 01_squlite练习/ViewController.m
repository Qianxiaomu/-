//
//  ViewController.m
//  01_squlite练习
//
//  Created by qingyun on 15/10/20.
//  Copyright (c) 2015年 lmy. All rights reserved.
//

#import "ViewController.h"
#import "InsertViewController.h"
#import "DBHandleOpration.h"
#import "ClassMateMode.h"
#import "EditViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating,UIGestureRecognizerDelegate>
@property (nonatomic, strong)UISearchController *searchController;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)NSMutableArray *beSearchedClassMate;
@property (nonatomic)BOOL isSecarching;
//@property (nonatomic, strong)ClassMateMode *mode;
@property (nonatomic, strong)EditViewController *editvc;
@property (nonatomic) CFTimeInterval minimumPressDuration;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView];
    _dataArray = [NSMutableArray array];
    _editvc = [EditViewController new];
    _beSearchedClassMate = [NSMutableArray array];
    self.title = @"通讯录";
    [self setTableView];
    // Do any additional setup after loading the view, typically from a nib.
}
//刷新ui
-(void)viewWillAppear:(BOOL)animated
{
    NSMutableArray *arr=[[DBHandleOpration ShardDBHandle] selectAll];
    if (arr) {
        
        _dataArray=arr;
        //  [_dataArr arrayByAddingObjectsFromArray:arr];
        _beSearchedClassMate = _dataArray;
        //刷新tableView
        [_tableView reloadData];
    }
    

}

-(void)setTableView
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    tableView.dataSource =self;
    tableView.delegate =self;
    [self.view addSubview:tableView];
    [tableView setTag:100];
    _tableView = tableView;
}


-(void)addValues
{
    InsertViewController *insertvc=[[InsertViewController alloc]init];
    [self.navigationController pushViewController:insertvc animated:YES];
}

//在tableview的headerView上添加搜索框
-(void)addSearchController
{
    _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    _searchController.searchResultsUpdater = self;
    _tableView.tableHeaderView = _searchController.searchBar;

}
//设置导航栏上右边的按钮
-(void)addSubView
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addValues)];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(addSearchController)];
    self.navigationItem.rightBarButtonItems = @[item,item1];
    
}
#pragma mark -UITableViewDataSource,UITableViewDelegate
//UITableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isSecarching) {
        return _beSearchedClassMate.count;
    }
    return _dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
        longPressGesture.minimumPressDuration= 1;
        // [cell setTag:10];
        [cell addGestureRecognizer:longPressGesture];
    }
    //cell赋值
    ClassMateMode *mode=[[ClassMateMode alloc]init];
    if (_isSecarching) {
        mode = _beSearchedClassMate[indexPath.row];
    }else
    {
        mode=_dataArray[indexPath.row];
    }
    cell.imageView.image=[UIImage imageWithData:mode.ICON];
    cell.textLabel.text=mode.NAME;
    cell.detailTextLabel.text=mode.PHONE;
    //添加长摁手势
    
    
    return cell;
}

-(void)longPressGesture:(UILongPressGestureRecognizer *)sender
{
    UITableView *table = (UITableView *)[self.view viewWithTag:100];

    CGPoint point = [sender locationInView:table];
    NSIndexPath *indexPath = [table indexPathForRowAtPoint:point];
    if (sender.state == UIGestureRecognizerStateBegan) {
    
        if (indexPath == nil) {
            return;
        }else
        {
            _editvc.model = _dataArray[indexPath.row];
            UIMenuItem *editItem = [[UIMenuItem alloc]initWithTitle:@"编辑" action:@selector(editAction)];
            UIMenuItem *deleteItem1 = [[UIMenuItem alloc]initWithTitle:@"取消" action:@selector(cancelAction)];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            menuController.menuItems = @[editItem,deleteItem1];
            //UITableViewCell *cell =(UITableViewCell *)sender.view;
            [menuController setTargetRect:[table rectForRowAtIndexPath:indexPath] inView:table];
            [self becomeFirstResponder];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
    
}
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)editAction
{
    [self.navigationController pushViewController:_editvc animated:YES];
}

-(void)cancelAction
{
    NSLog(@"cancel");
}



#if 0
//push＋传值
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:_editvc animated:YES];
    //传值
    _editvc.model = _dataArray[indexPath.row];

}
#endif
//单元格的删除
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ClassMateMode *model = [[ClassMateMode alloc]init];
        model = _dataArray[indexPath.row];
        [_dataArray removeObject:model];
        if ([[DBHandleOpration ShardDBHandle]deleteValueForMode:model]) {
            NSLog(@"删除成功");
        };
        //[_dataArray removeObjectAtIndex:indexPath.row];
        //刷新数据库
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
#pragma mark - UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *filterStr = searchController.searchBar.text;
    // 如果filteredStr为nil，或者为空字符串@""
    if (!filterStr || filterStr.length == 0) {
        _isSecarching = NO;
        _beSearchedClassMate = _dataArray;
    }else
    {
        _isSecarching = YES;
    }
    //拿单元格中name跟搜索框中text进行比较
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.NAME CONTAINS[cd] %@",filterStr];
    NSMutableArray *filtedArray = [NSMutableArray array];
    NSArray *arr = [_dataArray filteredArrayUsingPredicate:predicate];
    [filtedArray addObjectsFromArray:arr];
    _beSearchedClassMate = filtedArray;

    [_tableView reloadData];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCell"]) {
        return NO;
    }
    return  YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
