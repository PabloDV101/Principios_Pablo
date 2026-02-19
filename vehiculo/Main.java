

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
	Automovil v1 = new Automovil("Volvo 550",120,4,5,4);
        v1.mostrarDatos();
        v1.pruebaDelMotor();
	
	System.out.println("\n");
	Motocicleta m1 = new Motocicleta("Italika",120,2,2);
	m1.mostrarDatos();
	m1.pruebaDelMotor();

	System.out.println("\n");
	Autobus b1 = new Autobus("Mercedes",300,8,42,2,2);
	b1.mostrarDatos();
	b1.pruebaDelMotor();
	
	System.out.println("\n");
	Autobus b2 = new Autobus("Mercedes smart",250,6,25,1,1);
	b2.mostrarDatos();
	b2.pruebaDelMotor();

	}

  }
  


