#import "SettingsMultiTextViewController.h"
#import "WPStyleGuide.h"
#import "WPTableViewCell.h"
#import "WPTableViewSectionHeaderFooterView.h"

static CGVector const SettingsTextPadding = {11.0f, 3.0f};
static CGFloat const SettingsMinHeight = 41.0f;

@interface SettingsMultiTextViewController() <UITextViewDelegate>

@property (nonatomic, strong) UITableViewCell *textViewCell;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *hintView;

@end

@implementation SettingsMultiTextViewController

- (instancetype)initWithText:(NSString *)text
                 placeholder:(NSString *)placeholder
                        hint:(NSString *)hint
                  isPassword:(BOOL)isPassword
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _text = text;
        _placeholder = placeholder;
        _hint = hint;
        _isPassword = isPassword;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self initWithText:@"" placeholder:@"" hint:@"" isPassword:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.textView becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    [WPStyleGuide resetReadableMarginsForTableView:self.tableView];
    [WPStyleGuide configureColorsForView:self.view andTableView:self.tableView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self adjustCellSize];
}

- (UITableViewCell *)textViewCell
{
    if (_textViewCell) {
        return _textViewCell;
    }
    _textViewCell = [[WPTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    _textViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textView = [[UITextView alloc] initWithFrame:CGRectInset(self.textViewCell.bounds, SettingsTextPadding.dx, SettingsTextPadding.dy)];
    self.textView.text = self.text;
    self.textView.returnKeyType = UIReturnKeyDefault;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.secureTextEntry = self.isPassword;
    self.textView.font = [WPStyleGuide tableviewTextFont];
    self.textView.textColor = [WPStyleGuide darkGrey];
    self.textView.delegate = self;
    self.textView.scrollEnabled = NO;
    [_textViewCell.contentView addSubview:self.textView];
    
    return _textViewCell;
}

- (UIView *)hintView
{
    if (_hintView) {
        return _hintView;
    }
    WPTableViewSectionHeaderFooterView *footerView = [[WPTableViewSectionHeaderFooterView alloc] initWithReuseIdentifier:nil style:WPTableViewSectionStyleFooter];
    [footerView setTitle:_hint];
    _hintView = footerView;
    return _hintView;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.onValueChanged) {
        self.onValueChanged(self.textView.text);
    }
    [super viewWillDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        return self.textViewCell;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.hint;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    [WPStyleGuide configureTableViewSectionFooter:view];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self adjustCellSize];
}

- (void)adjustCellSize
{
    CGFloat widthInUse = CGRectGetWidth(self.textView.frame);
    CGFloat widthAvailable = CGRectGetWidth(self.textViewCell.contentView.bounds) - (2 * SettingsTextPadding.dx);
    CGSize size = [self.textView sizeThatFits:CGSizeMake(widthAvailable, CGFLOAT_MAX)];
    CGFloat height = size.height;

    if (fabs(self.tableView.rowHeight - height) > (self.textView.font.lineHeight * 0.5f) || widthInUse != widthAvailable)
    {
        [self.tableView beginUpdates];
        self.textView.frame = CGRectMake(SettingsTextPadding.dx, SettingsTextPadding.dy, widthAvailable, height);
        self.tableView.rowHeight = MAX(height, SettingsMinHeight) + SettingsTextPadding.dy;
        [self.tableView endUpdates];
    }
}

@end
