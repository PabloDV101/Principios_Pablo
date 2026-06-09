public class Main{
public static void main(String[] args){
Graphic circle = new Circle();

Graphic borderedCircle = new BorderDecorator(circle);
Graphic fancyCircle = new ShadowDecorator(new BorderDecorator(circle));

System.out.println("Circulo simple:");

System.out.println("\nCírculo con borde:");
borderedCircle.draw();

System.out.println("\nCírculo con borfde y sombra:");
fancyCircle.draw();
}
}
