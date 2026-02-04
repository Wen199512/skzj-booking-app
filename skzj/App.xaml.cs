namespace skzj
{
    public partial class App : Application
    {
        public App()
        {
            InitializeComponent();
        }

        protected override Window CreateWindow(IActivationState? activationState)
        {
            // 使用 NavigationPage 并将 LoginPage 设置为起始页
            return new Window(new NavigationPage(new LoginPage())
            {
                BarBackgroundColor = Color.FromArgb("#2196F3"),
                BarTextColor = Colors.White
            });
        }
    }
}