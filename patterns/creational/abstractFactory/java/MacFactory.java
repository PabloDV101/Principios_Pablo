public class MacFactory implements GUIFactory{
public Button createButton(){
return newMacButton();
}

public Window createWindow(){
return new MacWindow();
}
}
