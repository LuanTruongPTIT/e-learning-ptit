using Elearning.Api.Middleware;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Serilog;
using HealthChecks.UI.Client;
using Elearning.Common.Presentation.Endpoints;
using Elearning.Common.Infrastructure.Configuration;
using Elearning.Common.Infrastructure;
using Elearning.Api;
WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, loggerConfig) => loggerConfig.ReadFrom.Configuration(context.Configuration));
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();
builder.Services.AddEndpointsApiExplorer();

string databaseConnectionString = builder.Configuration.GetConnectionStringOrThrow("Database");
string redisConnectionString = builder.Configuration.GetConnectionStringOrThrow("Cache");


builder.Services.AddInfrastructure(
    DiagnosticsConfig.ServiceName,
    // [
    //     EventsModule.ConfigureConsumers(redisConnectionString),
    //     TicketingModule.ConfigureConsumers,
    //     AttendanceModule.ConfigureConsumers
    // ],
    databaseConnectionString,
    redisConnectionString);
builder.Services.AddOpenApi();


builder.Services.AddHealthChecks()
    .AddNpgSql(databaseConnectionString)
    .AddRedis(redisConnectionString);
// .AddKeyCloak(keyCloakHealthUrl);
WebApplication app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
  app.MapOpenApi();
}
app.MapHealthChecks("health", new HealthCheckOptions
{
  ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});

app.UseLogContext();
app.UseSerilogRequestLogging();

app.UseExceptionHandler();
app.MapEndpoints();


app.Run();
// public partial class Program;