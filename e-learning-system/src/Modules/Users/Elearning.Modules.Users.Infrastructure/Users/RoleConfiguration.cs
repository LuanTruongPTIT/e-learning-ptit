using Elearning.Modules.Users.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Elearning.Modules.Users.Infrastructure.Users;

internal sealed class RoleConfiguration : IEntityTypeConfiguration<Role>
{
  public void Configure(EntityTypeBuilder<Role> builder)
  {
    builder.ToTable("table_roles");
    builder.HasKey(r => r.name);
    builder.Property(r => r.name).HasMaxLength(50);
    builder
           .HasMany<Elearning.Modules.Users.Domain.Users.User>()
           .WithMany(u => u.Roles)
           .UsingEntity(joinBuilder =>
           {
             joinBuilder.ToTable("table_user_roles");

             joinBuilder.Property<string>("RolesName").HasColumnName("role_name");
           }
        );
    builder.HasData(
      Role.Administrator,
      Role.Lecturer,
      Role.Student
      );
  }
}