public class Application {

private Button button;
private Window window;

public Application(GUIFactory factory){
button = factory.createButton();
window = factory.createWindow();

}

public void run(){
button.paint();
window.render();
}
public static void main(String[] args){
GUIFactory factory = new WindowsFactory();
Application app = new Application(factory);
app.run();
}
}
