using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

namespace AvaloniaWindowsAndLinuxButtonPressCounter.ViewModels;

public partial class MainViewModel : ViewModelBase
{
    public string ButtonClickedText => $"Clicked the button {ButtonClickedAmount} times!";

    [ObservableProperty] [NotifyPropertyChangedFor(nameof(ButtonClickedText))]
    private int _buttonClickedAmount = 0;

    [RelayCommand]
    private void ButtonClick()
    {
        ButtonClickedAmount++;
    }
}