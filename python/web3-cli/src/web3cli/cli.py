"""Command-line interface for Web3 operations."""

import click
from rich.console import Console
from rich.table import Table
from .client import Web3Client
import os

console = Console()


@click.group()
@click.pass_context
def cli(ctx):
    """Web3 CLI - Ethereum blockchain tools."""
    ctx.ensure_object(dict)
    rpc_url = os.getenv("WEB3_PROVIDER_URL")
    ctx.obj['client'] = Web3Client(rpc_url)


@cli.command()
@click.pass_context
def info(ctx):
    """Display blockchain information."""
    client: Web3Client = ctx.obj['client']

    if not client.is_connected():
        console.print("[red]Error: Not connected to blockchain[/red]")
        return

    table = Table(title="Blockchain Info")
    table.add_column("Property", style="cyan")
    table.add_column("Value", style="green")

    table.add_row("Connected", "✓")
    table.add_row("Chain ID", str(client.get_chain_id()))
    table.add_row("Latest Block", str(client.get_block_number()))
    table.add_row("RPC URL", client.rpc_url)

    console.print(table)


@cli.command()
@click.argument('address')
@click.pass_context
def balance(ctx, address: str):
    """Get ETH balance for address."""
    client: Web3Client = ctx.obj['client']

    try:
        bal = client.get_balance(address)
        console.print(f"[green]Balance:[/green] {bal:.6f} ETH")
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")


@cli.command()
@click.argument('to_address')
@click.argument('amount', type=float)
@click.option('--private-key', envvar='PRIVATE_KEY', required=True, help='Sender private key')
@click.pass_context
def send(ctx, to_address: str, amount: float, private_key: str):
    """Send ETH to address."""
    client: Web3Client = ctx.obj['client']

    try:
        client.load_account(private_key)
        console.print(f"[cyan]Sending {amount} ETH to {to_address}...[/cyan]")

        tx_hash = client.send_transaction(to_address, amount)
        console.print(f"[green]Transaction sent:[/green] {tx_hash}")

        console.print("[cyan]Waiting for confirmation...[/cyan]")
        receipt = client.wait_for_transaction(tx_hash)

        if receipt['status'] == 1:
            console.print("[green]✓ Transaction confirmed![/green]")
        else:
            console.print("[red]✗ Transaction failed[/red]")

    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")


@cli.command()
@click.argument('block_number', type=int)
@click.pass_context
def block(ctx, block_number: int):
    """Get block information."""
    client: Web3Client = ctx.obj['client']

    try:
        block_data = client.w3.eth.get_block(block_number)

        table = Table(title=f"Block #{block_number}")
        table.add_column("Property", style="cyan")
        table.add_column("Value", style="green")

        table.add_row("Hash", block_data['hash'].hex())
        table.add_row("Parent Hash", block_data['parentHash'].hex())
        table.add_row("Miner", block_data['miner'])
        table.add_row("Timestamp", str(block_data['timestamp']))
        table.add_row("Transactions", str(len(block_data['transactions'])))
        table.add_row("Gas Used", str(block_data['gasUsed']))

        console.print(table)
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")


if __name__ == '__main__':
    cli()
