namespace Elearning.Modules.Domain.Users;
public sealed class Role
{
  public static readonly Role Administrator = new("Administrator");
  public static readonly Role Student = new("Student");
  public static readonly Role Lecturer = new("Lecturer");

  public Role(string name)
  {

  }
  private Role() { }

  public string Name { get; private set; }
}