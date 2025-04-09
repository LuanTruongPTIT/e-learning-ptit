using Elearning.Api.Middleware;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Serilog;
using HealthChecks.UI.Client;
using Elearning.Common.Presentation.Endpoints;
using Elearning.Common.Infrastructure.Configuration;
using Elearning.Common.Infrastructure;
using Elearning.Common.Application;
using Elearning.Api;
using System.Reflection;
using Microsoft.Extensions.DependencyInjection;
using Elearning.Api.Extensions;
using Elearning.Modules.Users.Infrastructure;
WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, loggerConfig) => loggerConfig.ReadFrom.Configuration(context.Configuration));
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();
builder.Services.AddEndpointsApiExplorer();

Assembly[] moduleApplicationAssemblies = [
    Elearning.Modules.Users.Application.AssemblyReference.Assembly,];

builder.Services.AddApplication(moduleApplicationAssemblies);
// builder.Services.AddSwaggerDocumentation();
string databaseConnectionString = builder.Configuration.GetConnectionStringOrThrow("Database");
Console.WriteLine(databaseConnectionString);
string redisConnectionString = builder.Configuration.GetConnectionStringOrThrow("Cache");
Console.WriteLine(redisConnectionString);
string rabbitmqConnectionString = builder.Configuration.GetConnectionStringOrThrow("RabbitMQ");
Console.WriteLine(rabbitmqConnectionString);


builder.Services.AddInfrastructure(
    DiagnosticsConfig.ServiceName,
    // [
    //     EventsModule.ConfigureConsumers(redisConnectionString),
    //     TicketingModule.ConfigureConsumers,
    //     AttendanceModule.ConfigureConsumers
    // ],
    databaseConnectionString,
    redisConnectionString,
    rabbitmqConnectionString);
// builder.Services.AddOpenApi();


builder.Services.AddHealthChecks()
    .AddNpgSql(databaseConnectionString)
    .AddRedis(redisConnectionString)
    .AddRabbitMQ();
// .AddKeyCloak(keyCloakHealthUrl);

builder.Configuration.AddModuleConfiguration(["users"]);
builder.Services.AddUsersModule(builder.Configuration);
WebApplication app = builder.Build();
Console.WriteLine(app.Environment.IsDevelopment());
if (app.Environment.IsDevelopment())
{
  app.ApplyMigrations();
  // app.MapOpenApi();
}
app.MapHealthChecks("health", new HealthCheckOptions
{
  ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});

app.UseLogContext();
app.UseSerilogRequestLogging();

app.UseExceptionHandler();
app.MapEndpoints();

Console.WriteLine("Running");
app.Run();

public partial class Program;