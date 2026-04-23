public class Main{
	
	public static void main(String[] args){
		Forma circuloRojo = new Circulo(new Rojo());
		Forma circuloAzul = new Circulo(new Azul());

		circuloRojo.dibujar();
		circuloAzul.dibujar();
	}

}
