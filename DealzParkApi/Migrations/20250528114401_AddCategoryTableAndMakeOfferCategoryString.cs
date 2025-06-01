using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace DealzParkApi.Migrations
{
    /// <inheritdoc />
    public partial class AddCategoryTableAndMakeOfferCategoryString : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Category",
                table: "Offers",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.CreateTable(
                name: "Categories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "CreatedAt", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 5, 28, 11, 44, 1, 866, DateTimeKind.Utc).AddTicks(3107), "Fashion" },
                    { 2, new DateTime(2025, 5, 28, 11, 44, 1, 866, DateTimeKind.Utc).AddTicks(3108), "Electronics" },
                    { 3, new DateTime(2025, 5, 28, 11, 44, 1, 866, DateTimeKind.Utc).AddTicks(3109), "Food" },
                    { 4, new DateTime(2025, 5, 28, 11, 44, 1, 866, DateTimeKind.Utc).AddTicks(3110), "Sports" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Categories");

            migrationBuilder.AlterColumn<string>(
                name: "Category",
                table: "Offers",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);
        }
    }
}
