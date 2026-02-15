

/**
 * Class Estudiante
 */
public class Estudiante extends Persona {

  //
  // Fields
  //

  public int matricula;
  public double promedio;
  public String licenciatura;
  
  //
  // Constructors
  //
  public Estudiante (String nombre, int edad, String sexo,
		  int matricula, double promedio, String licenciatura) {
 super(nombre,edad,sexo);
 this.matricula=matricula;
 this.promedio=promedio;
 this.licenciatura=licenciatura;

  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of matricula
   * @param newVar the new value of matricula
   */
  public void setMatricula (int newVar) {
    matricula = newVar;
  }

  /**
   * Get the value of matricula
   * @return the value of matricula
   */
  public int getMatricula () {
    return matricula;
  }

  /**
   * Set the value of promedio
   * @param newVar the new value of promedio
   */
  public void setPromedio (double newVar) {
    promedio = newVar;
  }

  /**
   * Get the value of promedio
   * @return the value of promedio
   */
  public double getPromedio () {
    return promedio;
  }

  /**
   * Set the value of licenciatura
   * @param newVar the new value of licenciatura
   */
  public void setLicenciatura (String newVar) {
    licenciatura = newVar;
  }

  /**
   * Get the value of licenciatura
   * @return the value of licenciatura
   */
  public String getLicenciatura () {
    return licenciatura;
  }

  //
  // Other methods
  //

  /**
   * @param        matricula
   * @param        promedio
   * @param        licenciatura
   */
  public void datosAlumno()
  {
	  System.out.println("nombre: "+nombre);
	  System.out.println("edad: "+edad);
	  System.out.println("sexo: "+sexo);
	  System.out.println("matricula: "+matricula);
	  System.out.println("promedio: "+promedio);
	  System.out.println("licenciatura: "+licenciatura);
	  System.out.println("");
  }


}
