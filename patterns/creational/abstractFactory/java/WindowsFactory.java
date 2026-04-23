public class WindowsFactory implements GUIFactory{
public Button createButton(){

return new WindowsButton();

}

public Window createWindow(){
return new WindowsWindow();
}
}
