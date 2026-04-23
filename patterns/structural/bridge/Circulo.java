class Circulo extends Forma{
public Circulo(Color color){
super(color);
}
public void dibujar(){
System.out.print("Circulo ");
color.aplicar();
}
}
