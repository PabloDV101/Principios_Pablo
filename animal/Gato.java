

/**
 * Class Gato
 */
public class Gato extends Animal implements Sonido {

  //
  // Fields
  //

  
  //
  // Constructors
  //
  public Gato () { };
  
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
   * @param        nombre
   */
  public Gato(String nombre)
  {
	  super(nombre);
  }


  /**
   */
  public void mover()
  {
	  System.out.println("El gato salta");
  }


  /**
   */
  public void hacerSonido()
  {
	  System.out.println("Miau");
  }


}
