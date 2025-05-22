// In DTOs/OfferCreationDto.cs
using System.ComponentModel.DataAnnotations;
using DealzParkApi.Models;

namespace DealzParkApi.DTOs;

public class OfferCreationDto
{
	[Required]
	[MaxLength(200)]
	public string PromotionalTitle { get; set; }

	public string? PromotionalImageUrl { get; set; }

	[Range(0, 100)]
	public int DiscountPercentage { get; set; }

	public string? ProductImageUrl { get; set; }

	[Required]
	public DateTime ValidFrom { get; set; }

	[Required]
	public DateTime ValidTo { get; set; }

	[Required]
	public OfferCategory Category { get; set; }

	[Required]
	public int ShopId { get; set; }
}