

/**
 * Class Main
 */
public class Main {

  //
  // Fields
  //

  
  //
  // Constructors
  //
  public Main () { };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  //
  // Other methods
  //

  /**
   * @param        args_
   */
  public static void main(String args [])
  {
	  Forma circulo = new Circulo();
	  Forma cuadrado = new Cuadrado();
	  Forma forma = new Forma();

	  forma.dibujar();
	  circulo.dibujar();
	  cuadrado.dibujar();
  }


}
