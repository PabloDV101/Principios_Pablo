

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
   * @param        args
   */
  public static void main(String []args)
  {
	  Persona myPerson = new Persona("Pablo",100);
	  myPerson.saludar();
	  System.out.println(myPerson.getEdad());
  }


}
