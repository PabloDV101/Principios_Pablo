

/**
 * Class Docente
 */
public class Docente extends Persona {

  //
  // Fields
  //

  public int idTrabajador;
  public double salario;
  public String departamento;
  
  //
  // Constructors
  //
  public Docente (String nombre, int edad, String sexo,
		  int idTrabajador, double salario, String departamento) {
 	super(nombre,edad,sexo);
	this.idTrabajador=idTrabajador;
	this.salario=salario;
	this.departamento=departamento;
  };
  
  //
  // Methods
  //


  //
  // Accessor methods
  //

  /**
   * Set the value of idTrabajador
   * @param newVar the new value of idTrabajador
   */
  public void setIdTrabajador (int newVar) {
    idTrabajador = newVar;
  }

  /**
   * Get the value of idTrabajador
   * @return the value of idTrabajador
   */
  public int getIdTrabajador () {
    return idTrabajador;
  }

  /**
   * Set the value of salario
   * @param newVar the new value of salario
   */
  public void setSalario (double newVar) {
    salario = newVar;
  }

  /**
   * Get the value of salario
   * @return the value of salario
   */
  public double getSalario () {
    return salario;
  }

  /**
   * Set the value of departamento
   * @param newVar the new value of departamento
   */
  public void setDepartamento (String newVar) {
    departamento = newVar;
  }

  /**
   * Get the value of departamento
   * @return the value of departamento
   */
  public String getDepartamento () {
    return departamento;
  }

  //
  // Other methods
  //

  /**
   * @param        idTrabajador
   * @param        salario
   * @param        departamento
   */
  public void datosDocente()
  {
	  System.out.println("nombre: "+nombre);
	  System.out.println("edad: "+edad);
	  System.out.println("sexo: "+sexo);
	  System.out.println("idTrabajador: "+idTrabajador);
	  System.out.println("salario: "+salario);
	  System.out.println("departamento: "+departamento);
	  System.out.println("");
  }


}
