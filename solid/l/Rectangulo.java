class Rectangulo implements Figura{
private int ancho;
private int alto;

public Rectangulo(int ancho,int alto){
this.ancho=ancho;
this.alto=alto;

}
public int getArea(){
return ancho*alto;
}

}
