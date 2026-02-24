

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
	  Auto auto = new Auto("Toyota");
	  Persona persona = new Persona("Pablo",auto);
	  persona.mostrarAuto();
  }


}
