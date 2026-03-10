

/**
 * Class Perro
 */
public class Perro extends Animal implements Sonido {

  //
  // Fields
  //

  
  //
  // Constructors
  //
  public Perro () { };
  
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
  public Perro(String nombre)
  {
	  super(nombre);
  }


  /**
   */
  @Override
  public void mover()
  {
	  System.out.println("El perro corre");
  }


  /**
   */
  public void hacerSonido()
  {
	  System.out.println("Guau Guau");
  }


}
