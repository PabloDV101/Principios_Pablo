

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
  public static void main(String args[])
  {
	  Perro perro = new Perro("Firulais");
	  Gato gato = new Gato("Michi");

	  perro.mover();
	  perro.hacerSonido();

	  gato.mover();
	  gato.hacerSonido();
  }


}
